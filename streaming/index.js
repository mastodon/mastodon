// @ts-check

const fs = require('fs');
const http = require('http');
const url = require('url');

const dotenv = require('dotenv');
const express = require('express');
const { JSDOM } = require('jsdom');
const log = require('npmlog');
const pg = require('pg');
const dbUrlToConfig = require('pg-connection-string').parse;
const metrics = require('prom-client');
const redis = require('redis');
const uuid = require('uuid');
const WebSocket = require('ws');

const environment = process.env.NODE_ENV || 'development';

dotenv.config({
  path: environment === 'production' ? '.env.production' : '.env',
});

log.level = process.env.LOG_LEVEL || 'verbose';

/**
 * @param {Object.<string, any>} defaultConfig
 * @param {string} redisUrl
 */
const redisUrlToClient = async (defaultConfig, redisUrl) => {
  const config = defaultConfig;

  let client;

  if (!redisUrl) {
    client = redis.createClient(config);
  } else if (redisUrl.startsWith('unix://')) {
    client = redis.createClient(Object.assign(config, {
      socket: {
        path: redisUrl.slice(7),
      },
    }));
  } else {
    client = redis.createClient(Object.assign(config, {
      url: redisUrl,
    }));
  }

  client.on('error', (err) => log.error('Redis Client Error!', err));
  await client.connect();

  return client;
};

/**
 * Attempts to safely parse a string as JSON, used when both receiving a message
 * from redis and when receiving a message from a client over a websocket
 * connection, this is why it accepts a `req` argument.
 * @param {string} json
 * @param {any?} req
 * @returns {Object.<string, any>|null}
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
        log.warn(req.requestId, `Error parsing message from user ${req.accountId}: ${err}`);
      } else {
        log.silly(req.requestId, `Error parsing message from ${req.remoteAddress}: ${err}`);
      }
    } else {
      log.warn(`Error parsing message from redis: ${err}`);
    }
    return null;
  }
};

/**
 * @param {Object.<string, any>} env the `process.env` value to read configuration from
 * @returns {Object.<string, any>} the configuration for the PostgreSQL connection
 */
const pgConfigFromEnv = (env) => {
  const pgConfigs = {
    development: {
      user:     env.DB_USER || pg.defaults.user,
      password: env.DB_PASS || pg.defaults.password,
      database: env.DB_NAME || 'mastodon_development',
      host:     env.DB_HOST || pg.defaults.host,
      port:     env.DB_PORT || pg.defaults.port,
    },

    production: {
      user:     env.DB_USER || 'mastodon',
      password: env.DB_PASS || '',
      database: env.DB_NAME || 'mastodon_production',
      host:     env.DB_HOST || 'localhost',
      port:     env.DB_PORT || 5432,
    },
  };

  let baseConfig;

  if (env.DATABASE_URL) {
    baseConfig = dbUrlToConfig(env.DATABASE_URL);

    // Support overriding the database password in the connection URL
    if (!baseConfig.password && env.DB_PASS) {
      baseConfig.password = env.DB_PASS;
    }
  } else {
    baseConfig = pgConfigs[environment];

    if (env.DB_SSLMODE) {
      switch(env.DB_SSLMODE) {
      case 'disable':
      case '':
        baseConfig.ssl = false;
        break;
      case 'no-verify':
        baseConfig.ssl = { rejectUnauthorized: false };
        break;
      default:
        baseConfig.ssl = {};
        break;
      }
    }
  }

  return {
    ...baseConfig,
    max: env.DB_POOL || 10,
    connectionTimeoutMillis: 15000,
    application_name: '',
  };
};

/**
 * @param {Object.<string, any>} env the `process.env` value to read configuration from
 * @returns {Object.<string, any>} configuration for the Redis connection
 */
const redisConfigFromEnv = (env) => {
  const redisNamespace = env.REDIS_NAMESPACE || null;

  const redisParams = {
    socket: {
      host: env.REDIS_HOST || '127.0.0.1',
      port: env.REDIS_PORT || 6379,
    },
    database: env.REDIS_DB || 0,
    password: env.REDIS_PASSWORD || undefined,
  };

  if (redisNamespace) {
    redisParams.namespace = redisNamespace;
  }

  const redisPrefix = redisNamespace ? `${redisNamespace}:` : '';

  return {
    redisParams,
    redisPrefix,
    redisUrl: env.REDIS_URL,
  };
};

const startServer = async () => {
  const app = express();

  app.set('trust proxy', process.env.TRUSTED_PROXY_IP ? process.env.TRUSTED_PROXY_IP.split(/(?:\s*,\s*|\s+)/) : 'loopback,uniquelocal');

  const pgPool = new pg.Pool(pgConfigFromEnv(process.env));
  const server = http.createServer(app);

  const { redisParams, redisUrl, redisPrefix } = redisConfigFromEnv(process.env);

  /**
   * @type {Object.<string, Array.<function(Object<string, any>): void>>}
   */
  const subs = {};

  const redisSubscribeClient = await redisUrlToClient(redisParams, redisUrl);
  const redisClient = await redisUrlToClient(redisParams, redisUrl);

  // Collect metrics from Node.js
  metrics.collectDefaultMetrics();

  new metrics.Gauge({
    name: 'pg_pool_total_connections',
    help: 'The total number of clients existing within the pool',
    collect() {
      this.set(pgPool.totalCount);
    },
  });

  new metrics.Gauge({
    name: 'pg_pool_idle_connections',
    help: 'The number of clients which are not checked out but are currently idle in the pool',
    collect() {
      this.set(pgPool.idleCount);
    },
  });

  new metrics.Gauge({
    name: 'pg_pool_waiting_queries',
    help: 'The number of queued requests waiting on a client when all clients are checked out',
    collect() {
      this.set(pgPool.waitingCount);
    },
  });

  const connectedClients = new metrics.Gauge({
    name: 'connected_clients',
    help: 'The number of clients connected to the streaming server',
    labelNames: ['type'],
  });

  connectedClients.set({ type: 'websocket' }, 0);
  connectedClients.set({ type: 'eventsource' }, 0);

  const connectedChannels = new metrics.Gauge({
    name: 'connected_channels',
    help: 'The number of channels the streaming server is streaming to',
    labelNames: [ 'type', 'channel' ]
  });

  const redisSubscriptions = new metrics.Gauge({
    name: 'redis_subscriptions',
    help: 'The number of Redis channels the streaming server is subscribed to',
  });

  // When checking metrics in the browser, the favicon is requested this
  // prevents the request from falling through to the API Router, which would
  // error for this endpoint:
  app.get('/favicon.ico', (req, res) => res.status(404).end());

  app.get('/api/v1/streaming/health', (req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('OK');
  });

  app.get('/metrics', async (req, res) => {
    try {
      res.set('Content-Type', metrics.register.contentType);
      res.end(await metrics.register.metrics());
    } catch (ex) {
      log.error(ex);
      res.status(500).end();
    }
  });

  /**
   * @param {string[]} channels
   * @returns {function(): void}
   */
  const subscriptionHeartbeat = channels => {
    const interval = 6 * 60;

    const tellSubscribed = () => {
      channels.forEach(channel => redisClient.set(`${redisPrefix}subscribed:${channel}`, '1', 'EX', interval * 3));
    };

    tellSubscribed();

    const heartbeat = setInterval(tellSubscribed, interval * 1000);

    return () => {
      clearInterval(heartbeat);
    };
  };

  /**
   * @param {string} message
   * @param {string} channel
   */
  const onRedisMessage = (message, channel) => {
    const callbacks = subs[channel];

    log.silly(`New message on channel ${channel}`);

    if (!callbacks) {
      return;
    }

    const json = parseJSON(message, null);
    if (!json) return;

    callbacks.forEach(callback => callback(json));
  };

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
    log.silly(`Adding listener for ${channel}`);

    subs[channel] = subs[channel] || [];

    if (subs[channel].length === 0) {
      log.verbose(`Subscribe ${channel}`);
      redisSubscribeClient.subscribe(channel, onRedisMessage);
      redisSubscriptions.inc();
    }

    subs[channel].push(callback);
  };

  /**
   * @param {string} channel
   * @param {SubscriptionListener} callback
   */
  const unsubscribe = (channel, callback) => {
    log.silly(`Removing listener for ${channel}`);

    if (!subs[channel]) {
      return;
    }

    subs[channel] = subs[channel].filter(item => item !== callback);

    if (subs[channel].length === 0) {
      log.verbose(`Unsubscribe ${channel}`);
      redisSubscribeClient.unsubscribe(channel);
      redisSubscriptions.dec();
      delete subs[channel];
    }
  };

  const FALSE_VALUES = [
    false,
    0,
    '0',
    'f',
    'F',
    'false',
    'FALSE',
    'off',
    'OFF',
  ];

  /**
   * @param {any} value
   * @returns {boolean}
   */
  const isTruthy = value =>
    value && !FALSE_VALUES.includes(value);

  /**
   * @param {any} req
   * @param {any} res
   * @param {function(Error=): void} next
   */
  const allowCrossDomain = (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Authorization, Accept, Cache-Control');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');

    next();
  };

  /**
   * @param {any} req
   * @param {any} res
   * @param {function(Error=): void} next
   */
  const setRequestId = (req, res, next) => {
    req.requestId = uuid.v4();
    res.header('X-Request-Id', req.requestId);

    next();
  };

  /**
   * @param {any} req
   * @param {any} res
   * @param {function(Error=): void} next
   */
  const setRemoteAddress = (req, res, next) => {
    req.remoteAddress = req.connection.remoteAddress;

    next();
  };

  /**
   * @param {any} req
   * @param {string[]} necessaryScopes
   * @returns {boolean}
   */
  const isInScope = (req, necessaryScopes) =>
    req.scopes.some(scope => necessaryScopes.includes(scope));

  /**
   * @param {string} token
   * @param {any} req
   * @returns {Promise.<void>}
   */
  const accountFromToken = (token, req) => new Promise((resolve, reject) => {
    pgPool.connect((err, client, done) => {
      if (err) {
        reject(err);
        return;
      }

      client.query('SELECT oauth_access_tokens.id, oauth_access_tokens.resource_owner_id, users.account_id, users.chosen_languages, oauth_access_tokens.scopes, devices.device_id FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id LEFT OUTER JOIN devices ON oauth_access_tokens.id = devices.access_token_id WHERE oauth_access_tokens.token = $1 AND oauth_access_tokens.revoked_at IS NULL LIMIT 1', [token], (err, result) => {
        done();

        if (err) {
          reject(err);
          return;
        }

        if (result.rows.length === 0) {
          err = new Error('Invalid access token');
          err.status = 401;

          reject(err);
          return;
        }

        req.accessTokenId = result.rows[0].id;
        req.scopes = result.rows[0].scopes.split(' ');
        req.accountId = result.rows[0].account_id;
        req.chosenLanguages = result.rows[0].chosen_languages;
        req.deviceId = result.rows[0].device_id;

        resolve();
      });
    });
  });

  /**
   * @param {any} req
   * @returns {Promise.<void>}
   */
  const accountFromRequest = (req) => new Promise((resolve, reject) => {
    const authorization = req.headers.authorization;
    const location      = url.parse(req.url, true);
    const accessToken   = location.query.access_token || req.headers['sec-websocket-protocol'];

    if (!authorization && !accessToken) {
      const err = new Error('Missing access token');
      err.status = 401;

      reject(err);
      return;
    }

    const token = authorization ? authorization.replace(/^Bearer /, '') : accessToken;

    resolve(accountFromToken(token, req));
  });

  /**
   * @param {any} req
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

  const PUBLIC_CHANNELS = [
    'public',
    'public:media',
    'public:local',
    'public:local:media',
    'public:remote',
    'public:remote:media',
    'hashtag',
    'hashtag:local',
  ];

  /**
   * @param {any} req
   * @param {string|undefined} channelName
   * @returns {Promise.<void>}
   */
  const checkScopes = (req, channelName) => new Promise((resolve, reject) => {
    log.silly(req.requestId, `Checking OAuth scopes for ${channelName}`);

    // When accessing public channels, no scopes are needed
    if (PUBLIC_CHANNELS.includes(channelName)) {
      resolve();
      return;
    }

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

    const err = new Error('Access token does not cover required scopes');
    err.status = 401;

    reject(err);
  });

  /**
   * @param {any} info
   * @param {function(boolean, number, string): void} callback
   */
  const wsVerifyClient = (info, callback) => {
    // When verifying the websockets connection, we no longer pre-emptively
    // check OAuth scopes and drop the connection if they're missing. We only
    // drop the connection if access without token is not allowed by environment
    // variables. OAuth scope checks are moved to the point of subscription
    // to a specific stream.

    accountFromRequest(info.req).then(() => {
      callback(true, undefined, undefined);
    }).catch(err => {
      log.error(info.req.requestId, err.toString());
      callback(false, 401, 'Unauthorized');
    });
  };

  /**
   * @typedef SystemMessageHandlers
   * @property {function(): void} onKill
   */

  /**
   * @param {any} req
   * @param {SystemMessageHandlers} eventHandlers
   * @returns {function(object): void}
   */
  const createSystemMessageListener = (req, eventHandlers) => {
    return message => {
      const { event } = message;

      log.silly(req.requestId, `System message for ${req.accountId}: ${event}`);

      if (event === 'kill') {
        log.verbose(req.requestId, `Closing connection for ${req.accountId} due to expired access token`);
        eventHandlers.onKill();
      } else if (event === 'filters_changed') {
        log.verbose(req.requestId, `Invalidating filters cache for ${req.accountId}`);
        req.cachedFilters = null;
      }
    };
  };

  /**
   * @param {any} req
   * @param {any} res
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
      unsubscribe(`${redisPrefix}${accessTokenChannelId}`, listener);
      unsubscribe(`${redisPrefix}${systemChannelId}`, listener);

      connectedChannels.labels({ type: 'eventsource', channel: 'system' }).dec(2);
    });

    subscribe(`${redisPrefix}${accessTokenChannelId}`, listener);
    subscribe(`${redisPrefix}${systemChannelId}`, listener);

    connectedChannels.labels({ type: 'eventsource', channel: 'system' }).inc(2);
  };

  /**
   * @param {any} req
   * @param {any} res
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
      const err = new Error('Unknown channel requested');
      err.status = 400;

      next(err);
      return;
    }

    accountFromRequest(req).then(() => checkScopes(req, channelName)).then(() => {
      subscribeHttpToSystemChannel(req, res);
    }).then(() => {
      next();
    }).catch(err => {
      next(err);
    });
  };

  /**
   * @param {Error} err
   * @param {any} req
   * @param {any} res
   * @param {function(Error=): void} next
   */
  const errorMiddleware = (err, req, res, next) => {
    log.error(req.requestId, err.toString());

    if (res.headersSent) {
      next(err);
      return;
    }

    res.writeHead(err.status || 500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: err.status ? err.toString() : 'An unexpected error occurred' }));
  };

  /**
   * @param {array} arr
   * @param {number=} shift
   * @returns {string}
   */
  const placeholders = (arr, shift = 0) => arr.map((_, i) => `$${i + 1 + shift}`).join(', ');

  /**
   * @param {string} listId
   * @param {any} req
   * @returns {Promise.<void>}
   */
  const authorizeListAccess = (listId, req) => new Promise((resolve, reject) => {
    const { accountId } = req;

    pgPool.connect((err, client, done) => {
      if (err) {
        reject();
        return;
      }

      client.query('SELECT id, account_id FROM lists WHERE id = $1 LIMIT 1', [listId], (err, result) => {
        done();

        if (err || result.rows.length === 0 || result.rows[0].account_id !== accountId) {
          reject();
          return;
        }

        resolve();
      });
    });
  });

  /**
   * @param {string[]} ids
   * @param {any} req
   * @param {function(string, string): void} output
   * @param {undefined | function(string[], SubscriptionListener): void} attachCloseHandler
   * @param {boolean=} needsFiltering
   * @param {boolean=} allowLocalOnly
   * @returns {SubscriptionListener}
   */
  const streamFrom = (ids, req, output, attachCloseHandler, needsFiltering = false, allowLocalOnly = false) => {
    const accountId = req.accountId || req.remoteAddress;

    log.verbose(req.requestId, `Starting stream from ${ids.join(', ')} for ${accountId}`);

    const transmit = (event, payload) => {
      // TODO: Replace "string"-based delete payloads with object payloads:
      const encodedPayload = typeof payload === 'object' ? JSON.stringify(payload) : payload;

      log.silly(req.requestId, `Transmitting for ${accountId}: ${event} ${encodedPayload}`);
      output(event, encodedPayload);
    };

    // The listener used to process each message off the redis subscription,
    // message here is an object with an `event` and `payload` property. Some
    // events also include a queued_at value, but this is being removed shortly.
    /** @type {SubscriptionListener} */
    const listener = message => {
      const { event, payload } = message;

      // Only send local-only statuses to logged-in users
      if ((event === 'update' || event === 'status.update') && payload.local_only && !(req.accountId && allowLocalOnly)) {
        log.silly(req.requestId, `Message ${payload.id} filtered because it was local-only`);
        return;
      }

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
        transmit(event, payload);
        return;
      }

      // The rest of the logic from here on in this function is to handle
      // filtering of statuses:

      // Filter based on language:
      if (Array.isArray(req.chosenLanguages) && payload.language !== null && req.chosenLanguages.indexOf(payload.language) === -1) {
        log.silly(req.requestId, `Message ${payload.id} filtered by language (${payload.language})`);
        return;
      }

      // When the account is not logged in, it is not necessary to confirm the block or mute
      if (!req.accountId) {
        transmit(event, payload);
        return;
      }

      // Filter based on domain blocks, blocks, mutes, or custom filters:
      const targetAccountIds = [payload.account.id].concat(payload.mentions.map(item => item.id));
      const accountDomain = payload.account.acct.split('@')[1];

      // TODO: Move this logic out of the message handling loop
      pgPool.connect((err, client, releasePgConnection) => {
        if (err) {
          log.error(err);
          return;
        }

        const queries = [
          client.query(`SELECT 1
                        FROM blocks
                        WHERE (account_id = $1 AND target_account_id IN (${placeholders(targetAccountIds, 2)}))
                           OR (account_id = $2 AND target_account_id = $1)
                        UNION
                        SELECT 1
                        FROM mutes
                        WHERE account_id = $1
                          AND target_account_id IN (${placeholders(targetAccountIds, 2)})`, [req.accountId, payload.account.id].concat(targetAccountIds)),
        ];

        if (accountDomain) {
          queries.push(client.query('SELECT 1 FROM account_domain_blocks WHERE account_id = $1 AND domain = $2', [req.accountId, accountDomain]));
        }

        if (!payload.filtered && !req.cachedFilters) {
          queries.push(client.query('SELECT filter.id AS id, filter.phrase AS title, filter.context AS context, filter.expires_at AS expires_at, filter.action AS filter_action, keyword.keyword AS keyword, keyword.whole_word AS whole_word FROM custom_filter_keywords keyword JOIN custom_filters filter ON keyword.custom_filter_id = filter.id WHERE filter.account_id = $1 AND (filter.expires_at IS NULL OR filter.expires_at > NOW())', [req.accountId]));
        }

        Promise.all(queries).then(values => {
          releasePgConnection();

          // Handling blocks & mutes and domain blocks: If one of those applies,
          // then we don't transmit the payload of the event to the client
          if (values[0].rows.length > 0 || (accountDomain && values[1].rows.length > 0)) {
            return;
          }

          // If the payload already contains the `filtered` property, it means
          // that filtering has been applied on the ruby on rails side, as
          // such, we don't need to construct or apply the filters in streaming:
          if (Object.prototype.hasOwnProperty.call(payload, "filtered")) {
            transmit(event, payload);
            return;
          }

          // Handling for constructing the custom filters and caching them on the request
          // TODO: Move this logic out of the message handling lifecycle
          if (!req.cachedFilters) {
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
            Object.keys(req.cachedFilters).forEach((key) => {
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

    ids.forEach(id => {
      subscribe(`${redisPrefix}${id}`, listener);
    });

    if (typeof attachCloseHandler === 'function') {
      attachCloseHandler(ids.map(id => `${redisPrefix}${id}`), listener);
    }

    return listener;
  };

  /**
   * @param {any} req
   * @param {any} res
   * @returns {function(string, string): void}
   */
  const streamToHttp = (req, res) => {
    const accountId = req.accountId || req.remoteAddress;

    const channelName = channelNameFromPath(req);

    connectedClients.labels({ type: 'eventsource' }).inc();

    // In theory we'll always have a channel name, but channelNameFromPath can return undefined:
    if (typeof channelName === 'string') {
      connectedChannels.labels({ type: 'eventsource', channel: channelName }).inc();
    }

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('Transfer-Encoding', 'chunked');

    res.write(':)\n');

    const heartbeat = setInterval(() => res.write(':thump\n'), 15000);

    req.on('close', () => {
      log.verbose(req.requestId, `Ending stream for ${accountId}`);
      // We decrement these counters here instead of in streamHttpEnd as in that
      // method we don't have knowledge of the channel names
      connectedClients.labels({ type: 'eventsource' }).dec();
      // In theory we'll always have a channel name, but channelNameFromPath can return undefined:
      if (typeof channelName === 'string') {
        connectedChannels.labels({ type: 'eventsource', channel: channelName }).dec();
      }

      clearInterval(heartbeat);
    });

    return (event, payload) => {
      res.write(`event: ${event}\n`);
      res.write(`data: ${payload}\n\n`);
    };
  };

  /**
   * @param {any} req
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
   * @param {any} req
   * @param {any} ws
   * @param {string[]} streamName
   * @returns {function(string, string): void}
   */
  const streamToWs = (req, ws, streamName) => (event, payload) => {
    if (ws.readyState !== ws.OPEN) {
      log.error(req.requestId, 'Tried writing to closed socket');
      return;
    }

    ws.send(JSON.stringify({ stream: streamName, event, payload }), (err) => {
      if (err) {
        log.error(req.requestId, `Failed to send to websocket: ${err}`);
      }
    });
  };

  /**
   * @param {any} res
   */
  const httpNotFound = res => {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  };

  const api = express.Router();

  app.use(api);

  api.use(setRequestId);
  api.use(setRemoteAddress);
  api.use(allowCrossDomain);

  api.use(authenticationMiddleware);
  api.use(errorMiddleware);

  api.get('/api/v1/streaming/*', (req, res) => {
    channelNameToIds(req, channelNameFromPath(req), req.query).then(({ channelIds, options }) => {
      const onSend = streamToHttp(req, res);
      const onEnd = streamHttpEnd(req, subscriptionHeartbeat(channelIds));

      streamFrom(channelIds, req, onSend, onEnd, options.needsFiltering, options.allowLocalOnly);
    }).catch(err => {
      log.verbose(req.requestId, 'Subscription error:', err.toString());
      httpNotFound(res);
    });
  });

  const wss = new WebSocket.Server({ server, verifyClient: wsVerifyClient });

  /**
   * @typedef StreamParams
   * @property {string} [tag]
   * @property {string} [list]
   * @property {string} [only_media]
   */

  /**
   * @param {any} req
   * @returns {string[]}
   */
  const channelsForUserStream = req => {
    const arr = [`timeline:${req.accountId}`];

    if (isInScope(req, ['crypto']) && req.deviceId) {
      arr.push(`timeline:${req.accountId}:${req.deviceId}`);
    }

    if (isInScope(req, ['read', 'read:notifications'])) {
      arr.push(`timeline:${req.accountId}:notifications`);
    }

    return arr;
  };

  /**
   * See app/lib/ascii_folder.rb for the canon definitions
   * of these constants
   */
  const NON_ASCII_CHARS        = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž';
  const EQUIVALENT_ASCII_CHARS = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz';

  /**
   * @param {string} str
   * @returns {string}
   */
  const foldToASCII = str => {
    const regex = new RegExp(NON_ASCII_CHARS.split('').join('|'), 'g');

    return str.replace(regex, match => {
      const index = NON_ASCII_CHARS.indexOf(match);
      return EQUIVALENT_ASCII_CHARS[index];
    });
  };

  /**
   * @param {string} str
   * @returns {string}
   */
  const normalizeHashtag = str => {
    return foldToASCII(str.normalize('NFKC').toLowerCase()).replace(/[^\p{L}\p{N}_\u00b7\u200c]/gu, '');
  };

  /**
   * @param {any} req
   * @param {string} name
   * @param {StreamParams} params
   * @returns {Promise.<{ channelIds: string[], options: { needsFiltering: boolean } }>}
   */
  const channelNameToIds = (req, name, params) => new Promise((resolve, reject) => {
    switch (name) {
    case 'user':
      resolve({
        channelIds: channelsForUserStream(req),
        options: { needsFiltering: false, allowLocalOnly: true },
      });

      break;
    case 'user:notification':
      resolve({
        channelIds: [`timeline:${req.accountId}:notifications`],
        options: { needsFiltering: false, allowLocalOnly: true },
      });

      break;
    case 'public':
      resolve({
        channelIds: ['timeline:public'],
        options: { needsFiltering: true, allowLocalOnly: isTruthy(params.allow_local_only) },
      });

      break;
    case 'public:allow_local_only':
      resolve({
        channelIds: ['timeline:public'],
        options: { needsFiltering: true, allowLocalOnly: true },
      });

      break;
    case 'public:local':
      resolve({
        channelIds: ['timeline:public:local'],
        options: { needsFiltering: true, allowLocalOnly: true },
      });

      break;
    case 'public:remote':
      resolve({
        channelIds: ['timeline:public:remote'],
        options: { needsFiltering: true, allowLocalOnly: false },
      });

      break;
    case 'public:media':
      resolve({
        channelIds: ['timeline:public:media'],
        options: { needsFiltering: true, allowLocalOnly: isTruthy(params.allow_local_only) },
      });

      break;
    case 'public:allow_local_only:media':
      resolve({
        channelIds: ['timeline:public:media'],
        options: { needsFiltering: true, allowLocalOnly: true },
      });

      break;
    case 'public:local:media':
      resolve({
        channelIds: ['timeline:public:local:media'],
        options: { needsFiltering: true, allowLocalOnly: true },
      });

      break;
    case 'public:remote:media':
      resolve({
        channelIds: ['timeline:public:remote:media'],
        options: { needsFiltering: true, allowLocalOnly: false },
      });

      break;
    case 'direct':
      resolve({
        channelIds: [`timeline:direct:${req.accountId}`],
        options: { needsFiltering: false, allowLocalOnly: true },
      });

      break;
    case 'hashtag':
      if (!params.tag || params.tag.length === 0) {
        reject('No tag for stream provided');
      } else {
        resolve({
          channelIds: [`timeline:hashtag:${normalizeHashtag(params.tag)}`],
          options: { needsFiltering: true, allowLocalOnly: true },
        });
      }

      break;
    case 'hashtag:local':
      if (!params.tag || params.tag.length === 0) {
        reject('No tag for stream provided');
      } else {
        resolve({
          channelIds: [`timeline:hashtag:${normalizeHashtag(params.tag)}:local`],
          options: { needsFiltering: true, allowLocalOnly: true },
        });
      }

      break;
    case 'list':
      authorizeListAccess(params.list, req).then(() => {
        resolve({
          channelIds: [`timeline:list:${params.list}`],
          options: { needsFiltering: false, allowLocalOnly: true },
        });
      }).catch(() => {
        reject('Not authorized to stream this list');
      });

      break;
    default:
      reject('Unknown stream type');
    }
  });

  /**
   * @param {string} channelName
   * @param {StreamParams} params
   * @returns {string[]}
   */
  const streamNameFromChannelName = (channelName, params) => {
    if (channelName === 'list') {
      return [channelName, params.list];
    } else if (['hashtag', 'hashtag:local'].includes(channelName)) {
      return [channelName, params.tag];
    } else {
      return [channelName];
    }
  };

  /**
   * @typedef WebSocketSession
   * @property {any} socket
   * @property {any} request
   * @property {Object.<string, { channelName: string, listener: SubscriptionListener, stopHeartbeat: function(): void }>} subscriptions
   */

  /**
   * @param {WebSocketSession} session
   * @param {string} channelName
   * @param {StreamParams} params
   * @returns {void}
   */
  const subscribeWebsocketToChannel = ({ socket, request, subscriptions }, channelName, params) => {
    checkScopes(request, channelName).then(() => channelNameToIds(request, channelName, params)).then(({
      channelIds,
      options,
    }) => {
      if (subscriptions[channelIds.join(';')]) {
        return;
      }

      const onSend = streamToWs(request, socket, streamNameFromChannelName(channelName, params));
      const stopHeartbeat = subscriptionHeartbeat(channelIds);
      const listener = streamFrom(channelIds, request, onSend, undefined, options.needsFiltering, options.allowLocalOnly);

      connectedChannels.labels({ type: 'websocket', channel: channelName }).inc();

      subscriptions[channelIds.join(';')] = {
        channelName,
        listener,
        stopHeartbeat,
      };
    }).catch(err => {
      log.verbose(request.requestId, 'Subscription error:', err.toString());
      socket.send(JSON.stringify({ error: err.toString() }));
    });
  }


  const removeSubscription = (subscriptions, channelIds, request) => {
    log.verbose(request.requestId, `Ending stream from ${channelIds.join(', ')} for ${request.accountId}`);

    const subscription = subscriptions[channelIds.join(';')];

    if (!subscription) {
      return;
    }

    channelIds.forEach(channelId => {
      unsubscribe(`${redisPrefix}${channelId}`, subscription.listener);
    });

    connectedChannels.labels({ type: 'websocket', channel: subscription.channelName }).dec();
    subscription.stopHeartbeat();

    delete subscriptions[channelIds.join(';')];
  }

  /**
   * @param {WebSocketSession} session
   * @param {string} channelName
   * @param {StreamParams} params
   * @returns {void}
   */
  const unsubscribeWebsocketFromChannel = ({ socket, request, subscriptions }, channelName, params) => {
    channelNameToIds(request, channelName, params).then(({ channelIds }) => {
      removeSubscription(subscriptions, channelIds, request);
    }).catch(err => {
      log.verbose(request.requestId, 'Unsubscribe error:', err);

      // If we have a socket that is alive and open still, send the error back to the client:
      // FIXME: In other parts of the code ws === socket
      if (socket.isAlive && socket.readyState === socket.OPEN) {
        socket.send(JSON.stringify({ error: "Error unsubscribing from channel" }));
      }
    });
  }

  /**
   * @param {WebSocketSession} session
   */
  const subscribeWebsocketToSystemChannel = ({ socket, request, subscriptions }) => {
    const accessTokenChannelId = `timeline:access_token:${request.accessTokenId}`;
    const systemChannelId = `timeline:system:${request.accountId}`;

    const listener = createSystemMessageListener(request, {

      onKill() {
        socket.close();
      },

    });

    subscribe(`${redisPrefix}${accessTokenChannelId}`, listener);
    subscribe(`${redisPrefix}${systemChannelId}`, listener);

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

    connectedChannels.labels({ type: 'websocket', channel: 'system' }).inc(2);
  };

  /**
   * @param {string|string[]} arrayOrString
   * @returns {string}
   */
  const firstParam = arrayOrString => {
    if (Array.isArray(arrayOrString)) {
      return arrayOrString[0];
    } else {
      return arrayOrString;
    }
  };

  wss.on('connection', (ws, req) => {
    const location = url.parse(req.url, true);

    req.requestId = uuid.v4();
    req.remoteAddress = ws._socket.remoteAddress;

    ws.isAlive = true;

    ws.on('pong', () => {
      ws.isAlive = true;
    });

    connectedClients.labels({ type: 'websocket' }).inc();

    /**
     * @type {WebSocketSession}
     */
    const session = {
      socket: ws,
      request: req,
      subscriptions: {},
    };

    const onEnd = () => {
      const subscriptions = Object.keys(session.subscriptions);

      subscriptions.forEach(channelIds => {
        removeSubscription(session.subscriptions, channelIds.split(';'), req)
      });

      // ensure garbage collection:
      session.socket = null;
      session.request = null;
      session.subscriptions = {};

      connectedClients.labels({ type: 'websocket' }).dec();
    };

    ws.on('close', onEnd);
    ws.on('error', onEnd);

    ws.on('message', (data, isBinary) => {
      if (isBinary) {
        log.warn('socket', 'Received binary data, closing connection');
        ws.close(1003, 'The mastodon streaming server does not support binary messages');
        return;
      }
      const message = data.toString('utf8');

      const json = parseJSON(message, session.request);

      if (!json) return;

      const { type, stream, ...params } = json;

      if (type === 'subscribe') {
        subscribeWebsocketToChannel(session, firstParam(stream), params);
      } else if (type === 'unsubscribe') {
        unsubscribeWebsocketFromChannel(session, firstParam(stream), params);
      } else {
        // Unknown action type
      }
    });

    subscribeWebsocketToSystemChannel(session);

    if (location.query.stream) {
      subscribeWebsocketToChannel(session, firstParam(location.query.stream), location.query);
    }
  });

  setInterval(() => {
    wss.clients.forEach(ws => {
      if (ws.isAlive === false) {
        ws.terminate();
        return;
      }

      ws.isAlive = false;
      ws.ping('', false);
    });
  }, 30000);

  attachServerWithConfig(server, address => {
    log.warn(`Streaming API now listening on ${address}`);
  });

  const onExit = () => {
    server.close();
    process.exit(0);
  };

  const onError = (err) => {
    log.error(err);
    server.close();
    process.exit(0);
  };

  process.on('SIGINT', onExit);
  process.on('SIGTERM', onExit);
  process.on('exit', onExit);
  process.on('uncaughtException', onError);
};

/**
 * @param {any} server
 * @param {function(string): void} [onSuccess]
 */
const attachServerWithConfig = (server, onSuccess) => {
  if (process.env.SOCKET || process.env.PORT && isNaN(+process.env.PORT)) {
    server.listen(process.env.SOCKET || process.env.PORT, () => {
      if (onSuccess) {
        fs.chmodSync(server.address(), 0o666);
        onSuccess(server.address());
      }
    });
  } else {
    server.listen(+process.env.PORT || 4000, process.env.BIND || '127.0.0.1', () => {
      if (onSuccess) {
        onSuccess(`${server.address().address}:${server.address().port}`);
      }
    });
  }
};

startServer();
