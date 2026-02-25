// @ts-check

import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import url from 'node:url';

import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import { JSDOM } from 'jsdom';
import { WebSocketServer } from 'ws';

import * as Database from './database.js';
import { AuthenticationError, RequestError, extractStatusAndMessage as extractErrorStatusAndMessage } from './errors.js';
import { logger, httpLogger, initializeLogLevel, attachWebsocketHttpLogger, createWebsocketLogger } from './logging.js';
import { setupMetrics } from './metrics.js';
import * as Redis from './redis.js';
import { isTruthy, normalizeHashtag, firstParam } from './utils.js';

const environment = process.env.NODE_ENV || 'development';
const PERMISSION_VIEW_FEEDS = 0x0000000000100000;

// Correctly detect and load .env or .env.production file based on environment:
const dotenvFile = environment === 'production' ? '.env.production' : '.env';
const dotenvFilePath = path.resolve(
  url.fileURLToPath(
    new URL(path.join('..', dotenvFile), import.meta.url)
  )
);

dotenv.config({
  path: dotenvFilePath,
  quiet: true,
});

initializeLogLevel(process.env, environment);

/**
 * Declares the result type for accountFromToken / accountFromRequest.
 *
 * Note: This is here because jsdoc doesn't like importing types that
 * are nested in functions
 * @typedef ResolvedAccount
 * @property {string} accessTokenId
 * @property {string[]} scopes
 * @property {string} accountId
 * @property {string[]} chosenLanguages
 * @property {number} permissions
 */

/**
 * @typedef {http.IncomingMessage & ResolvedAccount & {
 *   path: string
 *   query: Record<string, unknown>
 *   remoteAddress?: string
 *   cachedFilters: unknown
 *   scopes: string[]
 *   necessaryScopes: string[]
 * }} Request
 */


/**
 * Attempts to safely parse a string as JSON, used when both receiving a message
 * from redis and when receiving a message from a client over a websocket
 * connection, this is why it accepts a `req` argument.
 * @param {string} json
 * @param {Request?} req
 * @returns {Object.<string, unknown>|null}
 */
const parseJSON = (json, req) => {
  try {
    return JSON.parse(json);
  } catch (err) {
    /* FIXME: This logging isn't great, and should probably be done at the
     * call-site of parseJSON, not in the method, but this would require changing
     * the signature of parseJSON to return something akin to a Result type:
     * [Error|null, null|Object<string,any}], and then handling the error
     * scenarios.
     */
    if (req) {
      if (req.accountId) {
        req.log.error({ err }, `Error parsing message from user ${req.accountId}`);
      } else {
        req.log.error({ err }, `Error parsing message from ${req.remoteAddress}`);
      }
    } else {
      logger.error({ err }, `Error parsing message from redis`);
    }
    return null;
  }
};

// Used for priming the counters/gauges for the various metrics that are
// per-channel
const CHANNEL_NAMES = [
  'system',
  'user',
  'user:notification',
  'list',
  'direct',
  'public',
  'public:media',
  'public:local',
  'public:local:media',
  'public:remote',
  'public:remote:media',
  'hashtag',
  'hashtag:local',
];

const startServer = async () => {
  const pgConfig = Database.configFromEnv(process.env, environment);
  const pgPool = Database.getPool(pgConfig, environment, logger);

  const metrics = setupMetrics(CHANNEL_NAMES, pgPool);

  const redisConfig = Redis.configFromEnv(process.env);
  const redisClient = Redis.createClient(redisConfig, logger);
  const server = http.createServer();
  const wss = new WebSocketServer({ noServer: true });

  /**
   * Adds a namespace to Redis keys or channel names
   * Fixes: https://github.com/redis/ioredis/issues/1910
   * @param {string} keyOrChannel
   * @returns {string}
   */
  function redisNamespaced(keyOrChannel) {
    if (redisConfig.namespace) {
      return `${redisConfig.namespace}:${keyOrChannel}`;
    } else {
      return keyOrChannel;
    }
  }

  /**
   * Removes the redis namespace from a channel name
   * @param {string} channel
   * @returns {string}
   */
  function redisUnnamespaced(channel) {
    if (typeof redisConfig.namespace === "string") {
      // Note: this removes the configured namespace and the colon that is used
      // to separate it:
      return channel.slice(redisConfig.namespace.length + 1);
    } else {
      return channel;
    }
  }

  // Set the X-Request-Id header on WebSockets:
  wss.on("headers", function onHeaders(headers, req) {
    headers.push(`X-Request-Id: ${req.id}`);
  });

  const app = express();

  app.set('trust proxy', process.env.TRUSTED_PROXY_IP ? process.env.TRUSTED_PROXY_IP.split(/(?:\s*,\s*|\s+)/) : 'loopback,uniquelocal');

  app.use(httpLogger);
  app.use(cors());

  // Handle eventsource & other http requests:
  server.on('request', app);

  // Handle upgrade requests:
  server.on('upgrade', async function handleUpgrade(request, socket, head) {
    // Setup the HTTP logger, since websocket upgrades don't get the usual http
    // logger. This decorates the `request` object.
    attachWebsocketHttpLogger(request);

    request.log.info("HTTP Upgrade Requested");

    /** @param {Error} err */
    const onSocketError = (err) => {
      request.log.error({ error: err }, err.message);
    };

    socket.on('error', onSocketError);

    /** @type {ResolvedAccount} */
    let resolvedAccount;

    try {
      // @ts-expect-error
      resolvedAccount = await accountFromRequest(request);
    } catch (err) {
      // Unfortunately for using the on('upgrade') setup, we need to manually
      // write a HTTP Response to the Socket to close the connection upgrade
      // attempt, so the following code is to handle all of that.
      const {statusCode, errorMessage } = extractErrorStatusAndMessage(err);

      /** @type {Record<string, string | number | import('pino-http').ReqId>} */
      const headers = {
        'Connection': 'close',
        'Content-Type': 'text/plain',
        'Content-Length': 0,
        'X-Request-Id': request.id,
        'X-Error-Message': errorMessage
      };

      // Ensure the socket is closed once we've finished writing to it:
      socket.once('finish', () => {
        socket.destroy();
      });

      // Write the HTTP response manually:
      socket.end(`HTTP/1.1 ${statusCode} ${http.STATUS_CODES[statusCode]}\r\n${Object.keys(headers).map((key) => `${key}: ${headers[key]}`).join('\r\n')}\r\n\r\n`);

      // Finally, log the error:
      request.log.error({
        err,
        res: {
          statusCode,
          headers
        }
      }, errorMessage);

      return;
    }

    // Remove the error handler, wss.handleUpgrade has its own:
    socket.removeListener('error', onSocketError);

    wss.handleUpgrade(request, socket, head, function done(ws) {
      request.log.info("Authenticated request & upgraded to WebSocket connection");

      const wsLogger = createWebsocketLogger(request, resolvedAccount);

      // Start the connection:
      wss.emit('connection', ws, request, wsLogger);
    });
  });

  /**
   * @type {Object.<string, Array.<function(Object<string, unknown>): void>>}
   */
  const subs = {};

  const redisSubscribeClient = Redis.createClient(redisConfig, logger);

  // When checking metrics in the browser, the favicon is requested this
  // prevents the request from falling through to the API Router, which would
  // error for this endpoint:
  app.get('/favicon.ico', (_req, res) => res.status(404).end());

  app.get('/api/v1/streaming/health', (_req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain', 'Cache-Control': 'private, no-store' });
    res.end('OK');
  });

  app.get('/metrics', metrics.requestHandler);

  /**
   * @param {string[]} channels
   * @returns {function(): void}
   */
  const subscriptionHeartbeat = channels => {
    const interval = 6 * 60;

    const tellSubscribed = () => {
      channels.forEach(channel => redisClient.set(redisNamespaced(`subscribed:${channel}`), '1', 'EX', interval * 3));
    };

    tellSubscribed();

    const heartbeat = setInterval(tellSubscribed, interval * 1000);

    return () => {
      clearInterval(heartbeat);
    };
  };

  /**
   * @param {string} channel
   * @param {string} message
   */
  const onRedisMessage = (channel, message) => {
    metrics.redisMessagesReceived.inc();
    logger.debug(`New message on channel ${channel}`);

    const key = redisUnnamespaced(channel);
    const callbacks = subs[key];
    if (!callbacks) {
      return;
    }

    const json = parseJSON(message, null);
    if (!json) return;

    callbacks.forEach(callback => callback(json));
  };
  redisSubscribeClient.on("message", onRedisMessage);

  /**
   * @callback SubscriptionListener
   * @param {ReturnType<parseJSON>} json of the message
   * @returns void
   */

  /**
   * @param {string} channel
   * @param {SubscriptionListener} callback
   */
  const subscribe = (channel, callback) => {
    logger.debug(`Adding listener for ${channel}`);

    subs[channel] = subs[channel] || [];

    if (subs[channel].length === 0) {
      logger.debug(`Subscribe ${channel}`);

      redisSubscribeClient.subscribe(redisNamespaced(channel), (err, count) => {
        if (err) {
          logger.error(`Error subscribing to ${channel}`);
        } else if (typeof count === 'number') {
          metrics.redisSubscriptions.set(count);
        }
      });
    }

    subs[channel].push(callback);
  };

  /**
   * @param {string} channel
   * @param {SubscriptionListener} callback
   */
  const unsubscribe = (channel, callback) => {
    logger.debug(`Removing listener for ${channel}`);

    if (!subs[channel]) {
      return;
    }

    subs[channel] = subs[channel].filter(item => item !== callback);

    if (subs[channel].length === 0) {
      logger.debug(`Unsubscribe ${channel}`);

      // FIXME: https://github.com/redis/ioredis/issues/1910
      redisSubscribeClient.unsubscribe(redisNamespaced(channel), (err, count) => {
        if (err) {
          logger.error(`Error unsubscribing to ${channel}`);
        } else if (typeof count === 'number') {
          metrics.redisSubscriptions.set(count);
        }
      });
      delete subs[channel];
    }
  };

  /**
   * @param {Request} req
   * @param {string[]} necessaryScopes
   * @returns {boolean}
   */
  const isInScope = (req, necessaryScopes) =>
    req.scopes.some(scope => necessaryScopes.includes(scope));

  /**
   * @param {string} token
   * @param {Request} req
   * @returns {Promise<ResolvedAccount>}
   */
  const accountFromToken = async (token, req) => {
    const result = await pgPool.query('SELECT oauth_access_tokens.id, oauth_access_tokens.resource_owner_id, users.account_id, users.chosen_languages, oauth_access_tokens.scopes, COALESCE(user_roles.permissions, 0) AS permissions FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id INNER JOIN accounts ON accounts.id = users.account_id LEFT OUTER JOIN user_roles ON user_roles.id = users.role_id WHERE oauth_access_tokens.token = $1 AND oauth_access_tokens.revoked_at IS NULL AND users.disabled IS FALSE AND accounts.suspended_at IS NULL LIMIT 1', [token]);

    if (result.rows.length === 0) {
      throw new AuthenticationError('Invalid access token');
    }

    req.accessTokenId = result.rows[0].id;
    req.scopes = result.rows[0].scopes.split(' ');
    req.accountId = result.rows[0].account_id;
    req.chosenLanguages = result.rows[0].chosen_languages;
    req.permissions = result.rows[0].permissions;

    return {
      accessTokenId: result.rows[0].id,
      scopes: result.rows[0].scopes.split(' '),
      accountId: result.rows[0].account_id,
      chosenLanguages: result.rows[0].chosen_languages,
      permissions: result.rows[0].permissions,
    };
  };

  /**
   * @param {Request} req
   * @returns {Promise<ResolvedAccount>}
   */
  const accountFromRequest = (req) => new Promise((resolve, reject) => {
    const authorization = req.headers.authorization;
    const location      = req.url ? url.parse(req.url, true) : undefined;
    const accessToken   = location?.query.access_token || req.headers['sec-websocket-protocol'];

    if (!authorization && !accessToken) {
      reject(new AuthenticationError('Missing access token'));
      return;
    }

    const token = authorization ? authorization.replace(/^Bearer /, '') : accessToken;

    // @ts-expect-error
    resolve(accountFromToken(token, req));
  });

  /**
   * @param {Request} req
   * @returns {string|undefined}
   */
  const channelNameFromPath = req => {
    const { path, query } = req;
    const onlyMedia = isTruthy(query.only_media);

    switch (path) {
    case '/api/v1/streaming/user':
      return 'user';
    case '/api/v1/streaming/user/notification':
      return 'user:notification';
    case '/api/v1/streaming/public':
      return onlyMedia ? 'public:media' : 'public';
    case '/api/v1/streaming/public/local':
      return onlyMedia ? 'public:local:media' : 'public:local';
    case '/api/v1/streaming/public/remote':
      return onlyMedia ? 'public:remote:media' : 'public:remote';
    case '/api/v1/streaming/hashtag':
      return 'hashtag';
    case '/api/v1/streaming/hashtag/local':
      return 'hashtag:local';
    case '/api/v1/streaming/direct':
      return 'direct';
    case '/api/v1/streaming/list':
      return 'list';
    default:
      return undefined;
    }
  };

  /**
   * @param {Request} req
   * @param {import('pino').Logger} logger
   * @param {string|undefined} channelName
   * @returns {Promise.<void>}
   */
  const checkScopes = (req, logger, channelName) => new Promise((resolve, reject) => {
    logger.debug(`Checking OAuth scopes for ${channelName}`);

    // The `read` scope has the highest priority, if the token has it
    // then it can access all streams
    const requiredScopes = ['read'];

    // When accessing specifically the notifications stream,
    // we need a read:notifications, while in all other cases,
    // we can allow access with read:statuses. Mind that the
    // user stream will not contain notifications unless
    // the token has either read or read:notifications scope
    // as well, this is handled separately.
    if (channelName === 'user:notification') {
      requiredScopes.push('read:notifications');
    } else {
      requiredScopes.push('read:statuses');
    }

    if (req.scopes && requiredScopes.some(requiredScope => req.scopes.includes(requiredScope))) {
      resolve();
      return;
    }

    reject(new AuthenticationError('Access token does not have the required scopes'));
  });

  /**
   * @typedef SystemMessageHandlers
   * @property {function(): void} onKill
   */

  /**
   * @param {Request} req
   * @param {SystemMessageHandlers} eventHandlers
   * @returns {SubscriptionListener}
   */
  const createSystemMessageListener = (req, eventHandlers) => {
    return message => {
      if (!message?.event) {
        return;
      }

      const { event } = message;

      req.log.debug(`System message for ${req.accountId}: ${event}`);

      if (event === 'kill') {
        req.log.debug(`Closing connection for ${req.accountId} due to expired access token`);
        eventHandlers.onKill();
      } else if (event === 'filters_changed') {
        req.log.debug(`Invalidating filters cache for ${req.accountId}`);
        req.cachedFilters = null;
      }
    };
  };

  /**
   * @param {Request} req
   * @param {http.OutgoingMessage} res
   */
  const subscribeHttpToSystemChannel = (req, res) => {
    const accessTokenChannelId = `timeline:access_token:${req.accessTokenId}`;
    const systemChannelId = `timeline:system:${req.accountId}`;

    const listener = createSystemMessageListener(req, {
      onKill() {
        res.end();
      },
    });

    res.on('close', () => {
      unsubscribe(accessTokenChannelId, listener);
      unsubscribe(systemChannelId, listener);

      metrics.connectedChannels.labels({ type: 'eventsource', channel: 'system' }).dec(2);
    });

    subscribe(accessTokenChannelId, listener);
    subscribe(systemChannelId, listener);

    metrics.connectedChannels.labels({ type: 'eventsource', channel: 'system' }).inc(2);
  };

  /**
   * @param {Request} req
   * @param {http.ServerResponse} res
   * @param {function(Error=): void} next
   */
  const authenticationMiddleware = (req, res, next) => {
    if (req.method === 'OPTIONS') {
      next();
      return;
    }

    const channelName = channelNameFromPath(req);

    // If no channelName can be found for the request, then we should terminate
    // the connection, as there's nothing to stream back
    if (!channelName) {
      next(new RequestError('Unknown channel requested'));
      return;
    }

    accountFromRequest(req).then(() => checkScopes(req, req.log, channelName)).then(() => {
      subscribeHttpToSystemChannel(req, res);
    }).then(() => {
      next();
    }).catch(err => {
      next(err);
    });
  };

  /**
   * @param {Error} err
   * @param {Request} req
   * @param {http.ServerResponse} res
   * @param {function(Error=): void} next
   */
  const errorMiddleware = (err, req, res, next) => {
    req.log.error({ err }, err.toString());

    if (res.headersSent) {
      next(err);
      return;
    }

    const {statusCode, errorMessage } = extractErrorStatusAndMessage(err);

    res.writeHead(statusCode, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: errorMessage }));
  };

  /**
   * @param {string[]} arr
   * @param {number=} shift
   * @returns {string}
   */
  const placeholders = (arr, shift = 0) => arr.map((_, i) => `$${i + 1 + shift}`).join(', ');

  /**
   * @param {string} listId
   * @param {Request} req
   * @returns {Promise.<void>}
   */
  const authorizeListAccess = async (listId, req) => {
    const { accountId } = req;

    const result = await pgPool.query('SELECT id, account_id FROM lists WHERE id = $1 AND account_id = $2 LIMIT 1', [listId, accountId]);

    if (result.rows.length === 0) {
      throw new AuthenticationError('List not found');
    }
  };

  /**
   * @param {string} kind
   * @param {Request} req
   * @returns {Promise.<{ localAccess: boolean, remoteAccess: boolean }>}
   */
  const getFeedAccessSettings = async (kind, req) => {
    const access = { localAccess: true, remoteAccess: true };

    if (req.permissions & PERMISSION_VIEW_FEEDS) {
      return access;
    }

    let localAccessVar, remoteAccessVar;

    if (kind === 'hashtag') {
      localAccessVar = 'local_topic_feed_access';
      remoteAccessVar = 'remote_topic_feed_access';
    } else {
      localAccessVar = 'local_live_feed_access';
      remoteAccessVar = 'remote_live_feed_access';
    }

    const result = await pgPool.query('SELECT var, value FROM settings WHERE var IN ($1, $2)', [localAccessVar, remoteAccessVar]);

    result.rows.forEach((row) => {
      if (row.var === localAccessVar) {
        access.localAccess = row.value !== "--- disabled\n";
      } else {
        access.remoteAccess = row.value !== "--- disabled\n";
      }
    });

    return access;
  };

  /**
   * @param {string[]} channelIds
   * @param {Request} req
   * @param {import('pino').Logger} log
   * @param {function(string, string): void} output
   * @param {undefined | function(string[], SubscriptionListener): void} attachCloseHandler
   * @param {'websocket' | 'eventsource'} destinationType
   * @param {Object} options
   * @param {boolean} options.needsFiltering
   * @param {boolean=} options.filterLocal
   * @param {boolean=} options.filterRemote
   * @returns {SubscriptionListener}
   */
  const streamFrom = (channelIds, req, log, output, attachCloseHandler, destinationType, { needsFiltering, filterLocal, filterRemote } = { needsFiltering: false, filterLocal: false, filterRemote: false }) => {
    log.info({ channelIds }, `Starting stream`);

    /**
     * @param {string} event
     * @param {object|string} payload
     */
    const transmit = (event, payload) => {
      // TODO: Replace "string"-based delete payloads with object payloads:
      const encodedPayload = typeof payload === 'object' ? JSON.stringify(payload) : payload;

      metrics.messagesSent.labels({ type: destinationType }).inc(1);

      log.debug({ event, payload }, `Transmitting ${event} to ${req.accountId}`);

      output(event, encodedPayload);
    };

    // The listener used to process each message off the redis subscription,
    // message here is an object with an `event` and `payload` property. Some
    // events also include a queued_at value, but this is being removed shortly.

    /** @type {SubscriptionListener} */
    const listener = message => {
      if (!message?.event || !message?.payload) {
        return;
      }

      const { event, payload } = message;

      // Streaming only needs to apply filtering to some channels and only to
      // some events. This is because majority of the filtering happens on the
      // Ruby on Rails side when producing the event for streaming.
      //
      // The only events that require filtering from the streaming server are
      // `update` and `status.update`, all other events are transmitted to the
      // client as soon as they're received (pass-through).
      //
      // The channels that need filtering are determined in the function
      // `channelNameToIds` defined below:
      if (!needsFiltering || (event !== 'update' && event !== 'status.update')) {
        // @ts-expect-error
        transmit(event, payload);
        return;
      }

      // The rest of the logic from here on in this function is to handle
      // filtering of statuses:

      const localPayload = payload.account.username === payload.account.acct;
      if (localPayload ? filterLocal : filterRemote) {
        log.debug(`Message ${payload.id} filtered by feed settings`);
        return;
      }

      // Filter based on language:
      // @ts-expect-error
      if (Array.isArray(req.chosenLanguages) && req.chosenLanguages.indexOf(payload.language) === -1) {
        // @ts-expect-error
        log.debug(`Message ${payload.id} filtered by language (${payload.language})`);
        return;
      }

      // When the account is not logged in, it is not necessary to confirm the block or mute
      if (!req.accountId) {
        transmit(event, payload);
        return;
      }

      // Filter based on domain blocks, blocks, mutes, or custom filters:
      // @ts-expect-error
      const targetAccountIds = [payload.account.id].concat(payload.mentions.map(item => item.id));
      // @ts-expect-error
      const accountDomain = payload.account.acct.split('@')[1];

      // TODO: Move this logic out of the message handling loop
      pgPool.connect((err, client, releasePgConnection) => {
        if (err) {
          log.error(err);
          return;
        }

        const queries = [
          // @ts-expect-error
          client.query(`SELECT 1
                        FROM blocks
                        WHERE (account_id = $1 AND target_account_id IN (${placeholders(targetAccountIds, 2)}))
                           OR (account_id = $2 AND target_account_id = $1)
                        UNION
                        SELECT 1
                        FROM mutes
                        WHERE account_id = $1
                          AND target_account_id IN (${placeholders(targetAccountIds, 2)})`, [req.accountId, payload.
                          // @ts-expect-error
                          account.id].concat(targetAccountIds)),
        ];

        if (accountDomain) {
          // @ts-expect-error
          queries.push(client.query('SELECT 1 FROM account_domain_blocks WHERE account_id = $1 AND domain = $2', [req.accountId, accountDomain]));
        }

        // @ts-expect-error
        if (!payload.filtered && !req.cachedFilters) {
          // @ts-expect-error
          queries.push(client.query('SELECT filter.id AS id, filter.phrase AS title, filter.context AS context, filter.expires_at AS expires_at, filter.action AS filter_action, keyword.keyword AS keyword, keyword.whole_word AS whole_word FROM custom_filter_keywords keyword JOIN custom_filters filter ON keyword.custom_filter_id = filter.id WHERE filter.account_id = $1 AND (filter.expires_at IS NULL OR filter.expires_at > NOW())', [req.accountId]));
        }

        Promise.all(queries).then(values => {
          releasePgConnection();

          // Handling blocks & mutes and domain blocks: If one of those applies,
          // then we don't transmit the payload of the event to the client
          // @ts-expect-error
          if (values[0].rows.length > 0 || (accountDomain && values[1].rows.length > 0)) {
            return;
          }

          // If the payload already contains the `filtered` property, it means
          // that filtering has been applied on the ruby on rails side, as
          // such, we don't need to construct or apply the filters in streaming:
          if (Object.hasOwn(payload, "filtered")) {
            transmit(event, payload);
            return;
          }

          // Handling for constructing the custom filters and caching them on the request
          // TODO: Move this logic out of the message handling lifecycle
          // @ts-ignore
          if (!req.cachedFilters) {
            // @ts-expect-error
            const filterRows = values[accountDomain ? 2 : 1].rows;

            req.cachedFilters = filterRows.reduce((cache, filter) => {
              if (cache[filter.id]) {
                cache[filter.id].keywords.push([filter.keyword, filter.whole_word]);
              } else {
                cache[filter.id] = {
                  keywords: [[filter.keyword, filter.whole_word]],
                  expires_at: filter.expires_at,
                  filter: {
                    id: filter.id,
                    title: filter.title,
                    context: filter.context,
                    expires_at: filter.expires_at,
                    // filter.filter_action is the value from the
                    // custom_filters.action database column, it is an integer
                    // representing a value in an enum defined by Ruby on Rails:
                    //
                    // enum { warn: 0, hide: 1 }
                    filter_action: ['warn', 'hide'][filter.filter_action],
                  },
                };
              }

              return cache;
            }, {});

            // Construct the regular expressions for the custom filters: This
            // needs to be done in a separate loop as the database returns one
            // filterRow per keyword, so we need all the keywords before
            // constructing the regular expression
            // @ts-expect-error
            Object.keys(req.cachedFilters).forEach((key) => {
              // @ts-expect-error
              req.cachedFilters[key].regexp = new RegExp(req.cachedFilters[key].keywords.map(([keyword, whole_word]) => {
                let expr = keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

                if (whole_word) {
                  if (/^[\w]/.test(expr)) {
                    expr = `\\b${expr}`;
                  }

                  if (/[\w]$/.test(expr)) {
                    expr = `${expr}\\b`;
                  }
                }

                return expr;
              }).join('|'), 'i');
            });
          }

          // Apply cachedFilters against the payload, constructing a
          // `filter_results` array of FilterResult entities
          if (req.cachedFilters) {
            const status = payload;
            // TODO: Calculate searchableContent in Ruby on Rails:
            // @ts-expect-error
            const searchableContent = ([status.spoiler_text || '', status.content].concat((status.poll && status.poll.options) ? status.poll.options.map(option => option.title) : [])).concat(status.media_attachments.map(att => att.description)).join('\n\n').replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');
            const searchableTextContent = JSDOM.fragment(searchableContent).textContent;

            const now = new Date();
            const filter_results = Object.values(req.cachedFilters).reduce((results, cachedFilter) => {
              // Check the filter hasn't expired before applying:
              if (cachedFilter.expires_at !== null && cachedFilter.expires_at < now) {
                return results;
              }

              // Just in-case JSDOM fails to find textContent in searchableContent
              if (!searchableTextContent) {
                return results;
              }

              const keyword_matches = searchableTextContent.match(cachedFilter.regexp);
              if (keyword_matches) {
                // results is an Array of FilterResult; status_matches is always
                // null as we only are only applying the keyword-based custom
                // filters, not the status-based custom filters.
                // https://docs.joinmastodon.org/entities/FilterResult/
                results.push({
                  filter: cachedFilter.filter,
                  keyword_matches,
                  status_matches: null
                });
              }

              return results;
            }, []);

            // Send the payload + the FilterResults as the `filtered` property
            // to the streaming connection. To reach this code, the `event` must
            // have been either `update` or `status.update`, meaning the
            // `payload` is a Status entity, which has a `filtered` property:
            //
            // filtered: https://docs.joinmastodon.org/entities/Status/#filtered
            transmit(event, {
              ...payload,
              filtered: filter_results
            });
          } else {
            transmit(event, payload);
          }
        }).catch(err => {
          log.error(err);
          releasePgConnection();
        });
      });
    };

    channelIds.forEach(id => {
      subscribe(id, listener);
    });

    if (typeof attachCloseHandler === 'function') {
      attachCloseHandler(channelIds, listener);
    }

    return listener;
  };

  /**
   * @param {Request} req
   * @param {http.ServerResponse} res
   * @returns {function(string, string): void}
   */
  const streamToHttp = (req, res) => {
    const channelName = channelNameFromPath(req);

    metrics.connectedClients.labels({ type: 'eventsource' }).inc();

    // In theory we'll always have a channel name, but channelNameFromPath can return undefined:
    if (typeof channelName === 'string') {
      metrics.connectedChannels.labels({ type: 'eventsource', channel: channelName }).inc();
    }

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'private, no-store');
    res.setHeader('Transfer-Encoding', 'chunked');

    res.write(':)\n');

    const heartbeat = setInterval(() => res.write(':thump\n\n'), 15000);

    req.on('close', () => {
      req.log.info({ accountId: req.accountId }, `Ending stream`);

      // We decrement these counters here instead of in streamHttpEnd as in that
      // method we don't have knowledge of the channel names
      metrics.connectedClients.labels({ type: 'eventsource' }).dec();
      // In theory we'll always have a channel name, but channelNameFromPath can return undefined:
      if (typeof channelName === 'string') {
        metrics.connectedChannels.labels({ type: 'eventsource', channel: channelName }).dec();
      }

      clearInterval(heartbeat);
    });

    return (event, payload) => {
      res.write(`event: ${event}\n`);
      res.write(`data: ${payload}\n\n`);
    };
  };

  /**
   * @param {Request} req
   * @param {function(): void} [closeHandler]
   * @returns {function(string[], SubscriptionListener): void}
   */

  const streamHttpEnd = (req, closeHandler = undefined) => (ids, listener) => {
    req.on('close', () => {
      ids.forEach(id => {
        unsubscribe(id, listener);
      });

      if (closeHandler) {
        closeHandler();
      }
    });
  };

  /**
   * @param {http.IncomingMessage} req
   * @param {import('ws').WebSocket} ws
   * @param {string[]} streamName
   * @returns {function(string, string): void}
   */
  const streamToWs = (req, ws, streamName) => (event, payload) => {
    if (ws.readyState !== ws.OPEN) {
      req.log.error('Tried writing to closed socket');
      return;
    }

    const message = JSON.stringify({ stream: streamName, event, payload });

    ws.send(message, (/** @type {Error|undefined} */ err) => {
      if (err) {
        req.log.error({err}, `Failed to send to websocket`);
      }
    });
  };

  /**
   * @param {http.ServerResponse} res
   */
  const httpNotFound = res => {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  };

  const api = express.Router();

  app.use(api);

  // @ts-expect-error
  api.use(authenticationMiddleware);
  // @ts-expect-error
  api.use(errorMiddleware);

  api.get('/api/v1/streaming/*splat', (req, res) => {
    // @ts-expect-error
    const channelName = channelNameFromPath(req);

    // FIXME: In theory we'd never actually reach here due to
    // authenticationMiddleware catching this case, however, we need to refactor
    // how those middlewares work, so I'm adding the extra check in here.
    if (!channelName) {
      httpNotFound(res);
      return;
    }

    // @ts-expect-error
    channelNameToIds(req, channelName, req.query).then(({ channelIds, options }) => {
      // @ts-expect-error
      const onSend = streamToHttp(req, res);
      // @ts-expect-error
      const onEnd = streamHttpEnd(req, subscriptionHeartbeat(channelIds));

      // @ts-ignore
      streamFrom(channelIds, req, req.log, onSend, onEnd, 'eventsource', options);
    }).catch(err => {
      const {statusCode, errorMessage } = extractErrorStatusAndMessage(err);

      res.log.info({ err }, 'Eventsource subscription error');

      res.writeHead(statusCode, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: errorMessage }));
    });
  });

  /**
   * @typedef StreamParams
   * @property {string} [tag]
   * @property {string} [list]
   * @property {string} [only_media]
   */

  /**
   * @param {Request} req
   * @returns {string[]}
   */
  const channelsForUserStream = req => {
    const arr = [`timeline:${req.accountId}`];

    if (isInScope(req, ['read', 'read:notifications'])) {
      arr.push(`timeline:${req.accountId}:notifications`);
    }

    return arr;
  };

  /**
   * @param {Request} req
   * @param {string} name
   * @param {StreamParams} params
   * @returns {Promise.<{ channelIds: string[], options: { needsFiltering: boolean, filterLocal?: boolean, filterRemote?: boolean } }>}
   */
  const channelNameToIds = (req, name, params) => new Promise((resolve, reject) => {
    /**
     * @param {string} feedKind
     * @param {string} channelId
     * @param {{ needsFiltering: boolean }} options
     */
    const resolveFeed = (feedKind, channelId, options) => {
      getFeedAccessSettings(feedKind, req).then(({ localAccess, remoteAccess }) => {
        resolve({
          channelIds: [channelId],
          options: { ...options, filterLocal: !localAccess, filterRemote: !remoteAccess },
        });
      }).catch(() => {
        reject(new Error('Error getting feed access settings'));
      });
    };

    switch (name) {
    case 'user':
      resolve({
        channelIds: channelsForUserStream(req),
        options: { needsFiltering: false },
      });

      break;
    case 'user:notification':
      resolve({
        channelIds: [`timeline:${req.accountId}:notifications`],
        options: { needsFiltering: false },
      });

      break;
    case 'public':
      resolveFeed('public', 'timeline:public', { needsFiltering: true });
      break;
    case 'public:local':
      resolveFeed('public', 'timeline:public:local', { needsFiltering: true });
      break;
    case 'public:remote':
      resolveFeed('public', 'timeline:public:remote', { needsFiltering: true });
      break;
    case 'public:media':
      resolveFeed('public', 'timeline:public:media', { needsFiltering: true });
      break;
    case 'public:local:media':
      resolveFeed('public', 'timeline:public:local:media', { needsFiltering: true });
      break;
    case 'public:remote:media':
      resolveFeed('public', 'timeline:public:remote:media', { needsFiltering: true });
      break;
    case 'direct':
      resolve({
        channelIds: [`timeline:direct:${req.accountId}`],
        options: { needsFiltering: false },
      });

      break;
    case 'hashtag':
      if (!params.tag) {
        reject(new RequestError('Missing tag name parameter'));
        return;
      }

      resolveFeed('hashtag', `timeline:hashtag:${normalizeHashtag(params.tag)}`, { needsFiltering: true });

      break;
    case 'hashtag:local':
      if (!params.tag) {
        reject(new RequestError('Missing tag name parameter'));
        return;
      }

      resolveFeed('hashtag', `timeline:hashtag:${normalizeHashtag(params.tag)}:local`, { needsFiltering: true });

      break;
    case 'list':
      if (!params.list) {
        reject(new RequestError('Missing list name parameter'));
        return;
      }

      authorizeListAccess(params.list, req).then(() => {
        resolve({
          channelIds: [`timeline:list:${params.list}`],
          options: { needsFiltering: false },
        });
      }).catch(() => {
        reject(new AuthenticationError('Not authorized to stream this list'));
      });

      break;
    default:
      reject(new RequestError('Unknown stream type'));
    }
  });

  /**
   * @param {string} channelName
   * @param {StreamParams} params
   * @returns {string[]}
   */
  const streamNameFromChannelName = (channelName, params) => {
    if (channelName === 'list' && params.list) {
      return [channelName, params.list];
    } else if (['hashtag', 'hashtag:local'].includes(channelName) && params.tag) {
      return [channelName, params.tag];
    } else {
      return [channelName];
    }
  };

  /**
   * @typedef WebSocketSession
   * @property {import('ws').WebSocket & { isAlive: boolean}} websocket
   * @property {Request} request
   * @property {import('pino').Logger} logger
   * @property {Object.<string, { channelName: string, listener: SubscriptionListener, stopHeartbeat: function(): void }>} subscriptions
   */

  /**
   * @param {WebSocketSession} session
   * @param {string} channelName
   * @param {StreamParams} params
   * @returns {void}
   */
  const subscribeWebsocketToChannel = ({ websocket, request, logger, subscriptions }, channelName, params) => {
    checkScopes(request, logger, channelName).then(() => channelNameToIds(request, channelName, params)).then(({
      channelIds,
      options,
    }) => {
      if (subscriptions[channelIds.join(';')]) {
        return;
      }

      const onSend = streamToWs(request, websocket, streamNameFromChannelName(channelName, params));
      const stopHeartbeat = subscriptionHeartbeat(channelIds);
      const listener = streamFrom(channelIds, request, logger, onSend, undefined, 'websocket', options);

      metrics.connectedChannels.labels({ type: 'websocket', channel: channelName }).inc();

      subscriptions[channelIds.join(';')] = {
        channelName,
        listener,
        stopHeartbeat,
      };
    }).catch(err => {
      const {statusCode, errorMessage } = extractErrorStatusAndMessage(err);

      logger.error({ err }, 'Websocket subscription error');

      // If we have a socket that is alive and open still, send the error back to the client:
      if (websocket.isAlive && websocket.readyState === websocket.OPEN) {
        websocket.send(JSON.stringify({
          error: errorMessage,
          status: statusCode
        }));
      }
    });
  };

  /**
   * @param {WebSocketSession} session
   * @param {string[]} channelIds
   */
  const removeSubscription = ({ request, logger, subscriptions }, channelIds) => {
    logger.info({ channelIds, accountId: request.accountId }, `Ending stream`);

    const subscription = subscriptions[channelIds.join(';')];

    if (!subscription) {
      return;
    }

    channelIds.forEach(channelId => {
      unsubscribe(channelId, subscription.listener);
    });

    metrics.connectedChannels.labels({ type: 'websocket', channel: subscription.channelName }).dec();
    subscription.stopHeartbeat();

    delete subscriptions[channelIds.join(';')];
  };

  /**
   * @param {WebSocketSession} session
   * @param {string} channelName
   * @param {StreamParams} params
   * @returns {void}
   */
  const unsubscribeWebsocketFromChannel = (session, channelName, params) => {
    const { websocket, request, logger } = session;

    channelNameToIds(request, channelName, params).then(({ channelIds }) => {
      removeSubscription(session, channelIds);
    }).catch(err => {
      logger.error({err}, 'Websocket unsubscribe error');

      // If we have a socket that is alive and open still, send the error back to the client:
      if (websocket.isAlive && websocket.readyState === websocket.OPEN) {
        // TODO: Use a better error response here
        websocket.send(JSON.stringify({ error: "Error unsubscribing from channel" }));
      }
    });
  };

  /**
   * @param {WebSocketSession} session
   */
  const subscribeWebsocketToSystemChannel = ({ websocket, request, subscriptions }) => {
    const accessTokenChannelId = `timeline:access_token:${request.accessTokenId}`;
    const systemChannelId = `timeline:system:${request.accountId}`;

    const listener = createSystemMessageListener(request, {
      onKill() {
        websocket.close();
      },
    });

    subscribe(accessTokenChannelId, listener);
    subscribe(systemChannelId, listener);

    subscriptions[accessTokenChannelId] = {
      channelName: 'system',
      listener,
      stopHeartbeat: () => {
      },
    };

    subscriptions[systemChannelId] = {
      channelName: 'system',
      listener,
      stopHeartbeat: () => {
      },
    };

    metrics.connectedChannels.labels({ type: 'websocket', channel: 'system' }).inc(2);
  };

  /**
   * @param {import('ws').WebSocket & { isAlive: boolean }} ws
   * @param {Request} req
   * @param {import('pino').Logger} log
   */
  function onConnection(ws, req, log) {
    // Note: url.parse could throw, which would terminate the connection, so we
    // increment the connected clients metric straight away when we establish
    // the connection, without waiting:
    metrics.connectedClients.labels({ type: 'websocket' }).inc();

    // Setup connection keep-alive state:
    ws.isAlive = true;
    ws.on('pong', () => {
      ws.isAlive = true;
    });

    /**
     * @type {WebSocketSession}
     */
    const session = {
      websocket: ws,
      request: req,
      logger: log,
      subscriptions: {},
    };

    ws.on('close', function onWebsocketClose() {
      const subscriptions = Object.keys(session.subscriptions);

      subscriptions.forEach(channelIds => {
        removeSubscription(session, channelIds.split(';'));
      });

      // Decrement the metrics for connected clients:
      metrics.connectedClients.labels({ type: 'websocket' }).dec();

      // We need to unassign the session object as to ensure it correctly gets
      // garbage collected, without doing this we could accidentally hold on to
      // references to the websocket, the request, and the logger, causing
      // memory leaks.

      // This is commented out because `delete` only operated on object properties
      // It needs to be replaced by `session = undefined`, but it requires every calls to
      // `session` to check for it, thus a significant refactor
      // delete session;
    });

    // Note: immediately after the `error` event is emitted, the `close` event
    // is emitted. As such, all we need to do is log the error here.
    ws.on('error', (/** @type {Error} */ err) => {
      log.error(err);
    });

    ws.on('message', (data, isBinary) => {
      if (isBinary) {
        log.warn('Received binary data, closing connection');
        ws.close(1003, 'The mastodon streaming server does not support binary messages');
        return;
      }
      const message = data.toString('utf8');

      const json = parseJSON(message, session.request);

      if (!json) return;

      const { type, stream, ...params } = json;

      if (type === 'subscribe') {
        subscribeWebsocketToChannel(
          session,
          // @ts-expect-error
          firstParam(stream),
          params
        );
      } else if (type === 'unsubscribe') {
        unsubscribeWebsocketFromChannel(
          session,
          // @ts-expect-error
          firstParam(stream),
          params
        );
      } else {
        // Unknown action type
      }
    });

    subscribeWebsocketToSystemChannel(session);

    // Parse the URL for the connection arguments (if supplied), url.parse can throw:
    const location = req.url && url.parse(req.url, true);

    if (location && location.query.stream) {
      subscribeWebsocketToChannel(session, firstParam(location.query.stream), location.query);
    }
  }

  wss.on('connection', onConnection);

  setInterval(() => {
    wss.clients.forEach(ws => {
      // @ts-expect-error
      if (ws.isAlive === false) {
        ws.terminate();
        return;
      }

      // @ts-expect-error
      ws.isAlive = false;
      ws.ping('', false);
    });
  }, 30000);

  attachServerWithConfig(server, address => {
    logger.info(`Streaming API now listening on ${address}`);
  });

  const onExit = () => {
    server.close();
    process.exit(0);
  };

  /** @param {Error} err */
  const onError = (err) => {
    logger.error(err);

    server.close();
    process.exit(0);
  };

  process.on('SIGINT', onExit);
  process.on('SIGTERM', onExit);
  process.on('exit', onExit);
  process.on('uncaughtException', onError);
};

/**
 * @param {http.Server} server
 * @param {function(string): void} [onSuccess]
 */
const attachServerWithConfig = (server, onSuccess) => {
  if (process.env.SOCKET) {
    server.listen(process.env.SOCKET, () => {
      if (onSuccess) {
        // @ts-expect-error
        fs.chmodSync(server.address(), 0o666);
        // @ts-expect-error
        onSuccess(server.address());
      }
    });
  } else {
    const port = +(process.env.PORT || 4000);
    let bind = process.env.BIND ?? '127.0.0.1';
    // Web uses the URI syntax for BIND, which means IPv6 addresses may
    // be wrapped in square brackets:
    if (bind.startsWith('[') && bind.endsWith(']')) {
      bind = bind.slice(1, -1);
    }

    server.listen(port, bind, () => {
      if (onSuccess) {
        // @ts-expect-error
        onSuccess(`${server.address().address}:${server.address().port}`);
      }
    });
  }
};

startServer();
