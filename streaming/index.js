// @ts-check

const os = require('os');
const throng = require('throng');
const dotenv = require('dotenv');
const express = require('express');
const http = require('http');
const redis = require('redis');
const pg = require('pg');
const dbUrlToConfig = require('pg-connection-string').parse;
const log = require('npmlog');
const url = require('url');
const uuid = require('uuid');
const fs = require('fs');
const WebSocket = require('ws');
const { JSDOM } = require('jsdom');

const env = process.env.NODE_ENV || 'development';
const alwaysRequireAuth = process.env.LIMITED_FEDERATION_MODE === 'true' || process.env.WHITELIST_MODE === 'true' || process.env.AUTHORIZED_FETCH === 'true';

dotenv.config({
  path: env === 'production' ? '.env.production' : '.env',
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

const numWorkers = +process.env.STREAMING_CLUSTER_NUM || (env === 'development' ? 1 : Math.max(os.cpus().length - 1, 1));

/**
 * @param {string} json
 * @param {any} req
 * @return {Object.<string, any>|null}
 */
const parseJSON = (json, req) => {
  try {
    return JSON.parse(json);
  } catch (err) {
    if (req.accountId) {
      log.warn(req.requestId, `Error parsing message from user ${req.accountId}: ${err}`);
    } else {
      log.silly(req.requestId, `Error parsing message from ${req.remoteAddress}: ${err}`);
    }
    return null;
  }
};

const startMaster = () => {
  if (!process.env.SOCKET && process.env.PORT && isNaN(+process.env.PORT)) {
    log.warn('UNIX domain socket is now supported by using SOCKET. Please migrate from PORT hack.');
  }

  log.warn(`Starting streaming API server master with ${numWorkers} workers`);
};

const startWorker = async (workerId) => {
  log.warn(`Starting worker ${workerId}`);

  const pgConfigs = {
    development: {
      user:     process.env.DB_USER || pg.defaults.user,
      password: process.env.DB_PASS || pg.defaults.password,
      database: process.env.DB_NAME || 'mastodon_development',
      host:     process.env.DB_HOST || pg.defaults.host,
      port:     process.env.DB_PORT || pg.defaults.port,
    },

    production: {
      user:     process.env.DB_USER || 'mastodon',
      password: process.env.DB_PASS || '',
      database: process.env.DB_NAME || 'mastodon_production',
      host:     process.env.DB_HOST || 'localhost',
      port:     process.env.DB_PORT || 5432,
    },
  };

  const app = express();

  app.set('trust proxy', process.env.TRUSTED_PROXY_IP ? process.env.TRUSTED_PROXY_IP.split(/(?:\s*,\s*|\s+)/) : 'loopback,uniquelocal');

  const dbUrl = process.env.DATABASE_URL;
  const pgConfigsEnv = pgConfigs[env];
  const pgPoolConfigs = {
    max: process.env.DB_POOL || 10,
    connectionTimeoutMillis: 15000,
    ssl: !!process.env.DB_SSLMODE && process.env.DB_SSLMODE !== 'disable',
  };

  const pgPool = new pg.Pool(Object.assign(
    pgConfigsEnv,
    dbUrl ? dbUrlToConfig(dbUrl) : {},
    pgPoolConfigs,
  ));

  const server = http.createServer(app);
  const redisNamespace = process.env.REDIS_NAMESPACE || null;

  const redisParams = {
    socket: {
      host: process.env.REDIS_HOST || '127.0.0.1',
      port: process.env.REDIS_PORT || 6379,
    },
    database: process.env.REDIS_DB || 0,
    password: process.env.REDIS_PASSWORD || undefined,
  };

  if (redisNamespace) {
    redisParams.namespace = redisNamespace;
  }

  const redisPrefix = redisNamespace ? `${redisNamespace}:` : '';

  /**
   * @type {Object.<string, Array.<function(string): void>>}
   */
  const subs = {};

  const redisSubscribeClient = await redisUrlToClient(redisParams, process.env.REDIS_URL);
  const redisClient = await redisUrlToClient(redisParams, process.env.REDIS_URL);

  /**
   * @param {string[]} channels
   * @return {function(): void}
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

    callbacks.forEach(callback => callback(message));
  };

  /**
   * @param {string} channel
   * @param {function(string): void} callback
   */
  const subscribe = (channel, callback) => {
    log.silly(`Adding listener for ${channel}`);

    subs[channel] = subs[channel] || [];

    if (subs[channel].length === 0) {
      log.verbose(`Subscribe ${channel}`);
      redisSubscribeClient.subscribe(channel, onRedisMessage);
    }

    subs[channel].push(callback);
  };

  /**
   * @param {string} channel
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
   * @return {boolean}
   */
  const isTruthy = value =>
    value && !FALSE_VALUES.includes(value);

  /**
   * @param {any} req
   * @param {any} res
   * @param {function(Error=): void}
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
   * @param {function(Error=): void}
   */
  const setRequestId = (req, res, next) => {
    req.requestId = uuid.v4();
    res.header('X-Request-Id', req.requestId);

    next();
  };

  /**
   * @param {any} req
   * @param {any} res
   * @param {function(Error=): void}
   */
  const setRemoteAddress = (req, res, next) => {
    req.remoteAddress = req.connection.remoteAddress;

    next();
  };

  /**
   * @param {any} req
   * @param {string[]} necessaryScopes
   * @return {boolean}
   */
  const isInScope = (req, necessaryScopes) =>
    req.scopes.some(scope => necessaryScopes.includes(scope));

  /**
   * @param {string} token
   * @param {any} req
   * @return {Promise.<void>}
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
   * @param {boolean=} required
   * @return {Promise.<void>}
   */
  const accountFromRequest = (req, required = true) => new Promise((resolve, reject) => {
    const authorization = req.headers.authorization;
    const location      = url.parse(req.url, true);
    const accessToken   = location.query.access_token || req.headers['sec-websocket-protocol'];

    if (!authorization && !accessToken) {
      if (required) {
        const err = new Error('Missing access token');
        err.status = 401;

        reject(err);
        return;
      } else {
        resolve();
        return;
      }
    }

    const token = authorization ? authorization.replace(/^Bearer /, '') : accessToken;

    resolve(accountFromToken(token, req));
  });

  /**
   * @param {any} req
   * @return {string}
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
   * @param {string} channelName
   * @return {Promise.<void>}
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

    accountFromRequest(info.req, alwaysRequireAuth).then(() => {
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
   * @return {function(string): void}
   */
  const createSystemMessageListener = (req, eventHandlers) => {
    return message => {
      const json = parseJSON(message, req);

      if (!json) return;

      const { event } = json;

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
    });

    subscribe(`${redisPrefix}${accessTokenChannelId}`, listener);
    subscribe(`${redisPrefix}${systemChannelId}`, listener);
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

    accountFromRequest(req, alwaysRequireAuth).then(() => checkScopes(req, channelNameFromPath(req))).then(() => {
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
   * @return {string}
   */
  const placeholders = (arr, shift = 0) => arr.map((_, i) => `$${i + 1 + shift}`).join(', ');

  /**
   * @param {string} listId
   * @param {any} req
   * @return {Promise.<void>}
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
   * @param {function(string[], function(string): void): void} attachCloseHandler
   * @param {boolean=} needsFiltering
   * @return {function(string): void}
   */
  const streamFrom = (ids, req, output, attachCloseHandler, needsFiltering = false) => {
    const accountId = req.accountId || req.remoteAddress;

    log.verbose(req.requestId, `Starting stream from ${ids.join(', ')} for ${accountId}`);

    const listener = message => {
      const json = parseJSON(message, req);

      if (!json) return;

      const { event, payload, queued_at } = json;

      const transmit = () => {
        const now = new Date().getTime();
        const delta = now - queued_at;
        const encodedPayload = typeof payload === 'object' ? JSON.stringify(payload) : payload;

        log.silly(req.requestId, `Transmitting for ${accountId}: ${event} ${encodedPayload} Delay: ${delta}ms`);
        output(event, encodedPayload);
      };

      // Only messages that may require filtering are statuses, since notifications
      // are already personalized and deletes do not matter
      if (!needsFiltering || event !== 'update') {
        transmit();
        return;
      }

      const unpackedPayload = payload;
      const targetAccountIds = [unpackedPayload.account.id].concat(unpackedPayload.mentions.map(item => item.id));
      const accountDomain = unpackedPayload.account.acct.split('@')[1];

      if (Array.isArray(req.chosenLanguages) && unpackedPayload.language !== null && req.chosenLanguages.indexOf(unpackedPayload.language) === -1) {
        log.silly(req.requestId, `Message ${unpackedPayload.id} filtered by language (${unpackedPayload.language})`);
        return;
      }

      // When the account is not logged in, it is not necessary to confirm the block or mute
      if (!req.accountId) {
        transmit();
        return;
      }

      pgPool.connect((err, client, done) => {
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
                          AND target_account_id IN (${placeholders(targetAccountIds, 2)})`, [req.accountId, unpackedPayload.account.id].concat(targetAccountIds)),
        ];

        if (accountDomain) {
          queries.push(client.query('SELECT 1 FROM account_domain_blocks WHERE account_id = $1 AND domain = $2', [req.accountId, accountDomain]));
        }

        if (!unpackedPayload.filtered && !req.cachedFilters) {
          queries.push(client.query('SELECT filter.id AS id, filter.phrase AS title, filter.context AS context, filter.expires_at AS expires_at, filter.action AS filter_action, keyword.keyword AS keyword, keyword.whole_word AS whole_word FROM custom_filter_keywords keyword JOIN custom_filters filter ON keyword.custom_filter_id = filter.id WHERE filter.account_id = $1 AND (filter.expires_at IS NULL OR filter.expires_at > NOW())', [req.accountId]));
        }

        Promise.all(queries).then(values => {
          done();

          if (values[0].rows.length > 0 || (accountDomain && values[1].rows.length > 0)) {
            return;
          }

          if (!unpackedPayload.filtered && !req.cachedFilters) {
            const filterRows = values[accountDomain ? 2 : 1].rows;

            req.cachedFilters = filterRows.reduce((cache, row) => {
              if (cache[row.id]) {
                cache[row.id].keywords.push([row.keyword, row.whole_word]);
              } else {
                cache[row.id] = {
                  keywords: [[row.keyword, row.whole_word]],
                  expires_at: row.expires_at,
                  repr: {
                    id: row.id,
                    title: row.title,
                    context: row.context,
                    expires_at: row.expires_at,
                    filter_action: ['warn', 'hide'][row.filter_action],
                  },
                };
              }

              return cache;
            }, {});

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

          // Check filters
          if (req.cachedFilters && !unpackedPayload.filtered) {
            const status = unpackedPayload;
            const searchContent = ([status.spoiler_text || '', status.content].concat((status.poll && status.poll.options) ? status.poll.options.map(option => option.title) : [])).concat(status.media_attachments.map(att => att.description)).join('\n\n').replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');
            const searchIndex = JSDOM.fragment(searchContent).textContent;

            const now = new Date();
            payload.filtered = [];
            Object.values(req.cachedFilters).forEach((cachedFilter) => {
              if ((cachedFilter.expires_at === null || cachedFilter.expires_at > now)) {
                const keyword_matches = searchIndex.match(cachedFilter.regexp);
                if (keyword_matches) {
                  payload.filtered.push({
                    filter: cachedFilter.repr,
                    keyword_matches,
                  });
                }
              }
            });
          }

          transmit();
        }).catch(err => {
          log.error(err);
          done();
        });
      });
    };

    ids.forEach(id => {
      subscribe(`${redisPrefix}${id}`, listener);
    });

    if (attachCloseHandler) {
      attachCloseHandler(ids.map(id => `${redisPrefix}${id}`), listener);
    }

    return listener;
  };

  /**
   * @param {any} req
   * @param {any} res
   * @return {function(string, string): void}
   */
  const streamToHttp = (req, res) => {
    const accountId = req.accountId || req.remoteAddress;

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('Transfer-Encoding', 'chunked');

    res.write(':)\n');

    const heartbeat = setInterval(() => res.write(':thump\n'), 15000);

    req.on('close', () => {
      log.verbose(req.requestId, `Ending stream for ${accountId}`);
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
   * @return {function(string[]): void}
   */
  const streamHttpEnd = (req, closeHandler = undefined) => (ids) => {
    req.on('close', () => {
      ids.forEach(id => {
        unsubscribe(id);
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
   * @return {function(string, string): void}
   */
  const streamToWs = (req, ws, streamName) => (event, payload) => {
    if (ws.readyState !== ws.OPEN) {
      log.error(req.requestId, 'Tried writing to closed socket');
      return;
    }

    ws.send(JSON.stringify({ stream: streamName, event, payload }));
  };

  /**
   * @param {any} res
   */
  const httpNotFound = res => {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  };

  app.use(setRequestId);
  app.use(setRemoteAddress);
  app.use(allowCrossDomain);

  app.get('/api/v1/streaming/health', (req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('OK');
  });

  app.get('/metrics', (req, res) => server.getConnections((err, count) => {
    res.writeHeader(200, { 'Content-Type': 'application/openmetrics-text; version=1.0.0; charset=utf-8' });
    res.write('# TYPE connected_clients gauge\n');
    res.write('# HELP connected_clients The number of clients connected to the streaming server\n');
    res.write(`connected_clients ${count}.0\n`);
    res.write('# TYPE connected_channels gauge\n');
    res.write('# HELP connected_channels The number of Redis channels the streaming server is subscribed to\n');
    res.write(`connected_channels ${Object.keys(subs).length}.0\n`);
    res.write('# TYPE pg_pool_total_connections gauge\n');
    res.write('# HELP pg_pool_total_connections The total number of clients existing within the pool\n');
    res.write(`pg_pool_total_connections ${pgPool.totalCount}.0\n`);
    res.write('# TYPE pg_pool_idle_connections gauge\n');
    res.write('# HELP pg_pool_idle_connections The number of clients which are not checked out but are currently idle in the pool\n');
    res.write(`pg_pool_idle_connections ${pgPool.idleCount}.0\n`);
    res.write('# TYPE pg_pool_waiting_queries gauge\n');
    res.write('# HELP pg_pool_waiting_queries The number of queued requests waiting on a client when all clients are checked out\n');
    res.write(`pg_pool_waiting_queries ${pgPool.waitingCount}.0\n`);
    res.write('# EOF\n');
    res.end();
  }));

  app.use(authenticationMiddleware);
  app.use(errorMiddleware);

  app.get('/api/v1/streaming/*', (req, res) => {
    channelNameToIds(req, channelNameFromPath(req), req.query).then(({ channelIds, options }) => {
      const onSend = streamToHttp(req, res);
      const onEnd = streamHttpEnd(req, subscriptionHeartbeat(channelIds));

      streamFrom(channelIds, req, onSend, onEnd, options.needsFiltering);
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
   * @return {string[]}
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
   * @return {string}
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
   * @return {string}
   */
  const normalizeHashtag = str => {
    return foldToASCII(str.normalize('NFKC').toLowerCase()).replace(/[^\p{L}\p{N}_\u00b7\u200c]/gu, '');
  };

  /**
   * @param {any} req
   * @param {string} name
   * @param {StreamParams} params
   * @return {Promise.<{ channelIds: string[], options: { needsFiltering: boolean } }>}
   */
  const channelNameToIds = (req, name, params) => new Promise((resolve, reject) => {
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
      resolve({
        channelIds: ['timeline:public'],
        options: { needsFiltering: true },
      });

      break;
    case 'public:local':
      resolve({
        channelIds: ['timeline:public:local'],
        options: { needsFiltering: true },
      });

      break;
    case 'public:remote':
      resolve({
        channelIds: ['timeline:public:remote'],
        options: { needsFiltering: true },
      });

      break;
    case 'public:media':
      resolve({
        channelIds: ['timeline:public:media'],
        options: { needsFiltering: true },
      });

      break;
    case 'public:local:media':
      resolve({
        channelIds: ['timeline:public:local:media'],
        options: { needsFiltering: true },
      });

      break;
    case 'public:remote:media':
      resolve({
        channelIds: ['timeline:public:remote:media'],
        options: { needsFiltering: true },
      });

      break;
    case 'direct':
      resolve({
        channelIds: [`timeline:direct:${req.accountId}`],
        options: { needsFiltering: false },
      });

      break;
    case 'hashtag':
      if (!params.tag || params.tag.length === 0) {
        reject('No tag for stream provided');
      } else {
        resolve({
          channelIds: [`timeline:hashtag:${normalizeHashtag(params.tag)}`],
          options: { needsFiltering: true },
        });
      }

      break;
    case 'hashtag:local':
      if (!params.tag || params.tag.length === 0) {
        reject('No tag for stream provided');
      } else {
        resolve({
          channelIds: [`timeline:hashtag:${normalizeHashtag(params.tag)}:local`],
          options: { needsFiltering: true },
        });
      }

      break;
    case 'list':
      authorizeListAccess(params.list, req).then(() => {
        resolve({
          channelIds: [`timeline:list:${params.list}`],
          options: { needsFiltering: false },
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
   * @return {string[]}
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
   * @property {Object.<string, { listener: function(string): void, stopHeartbeat: function(): void }>} subscriptions
   */

  /**
   * @param {WebSocketSession} session
   * @param {string} channelName
   * @param {StreamParams} params
   */
  const subscribeWebsocketToChannel = ({ socket, request, subscriptions }, channelName, params) =>
    checkScopes(request, channelName).then(() => channelNameToIds(request, channelName, params)).then(({
      channelIds,
      options,
    }) => {
      if (subscriptions[channelIds.join(';')]) {
        return;
      }

      const onSend = streamToWs(request, socket, streamNameFromChannelName(channelName, params));
      const stopHeartbeat = subscriptionHeartbeat(channelIds);
      const listener = streamFrom(channelIds, request, onSend, undefined, options.needsFiltering);

      subscriptions[channelIds.join(';')] = {
        listener,
        stopHeartbeat,
      };
    }).catch(err => {
      log.verbose(request.requestId, 'Subscription error:', err.toString());
      socket.send(JSON.stringify({ error: err.toString() }));
    });

  /**
   * @param {WebSocketSession} session
   * @param {string} channelName
   * @param {StreamParams} params
   */
  const unsubscribeWebsocketFromChannel = ({ socket, request, subscriptions }, channelName, params) =>
    channelNameToIds(request, channelName, params).then(({ channelIds }) => {
      log.verbose(request.requestId, `Ending stream from ${channelIds.join(', ')} for ${request.accountId}`);

      const subscription = subscriptions[channelIds.join(';')];

      if (!subscription) {
        return;
      }

      const { listener, stopHeartbeat } = subscription;

      channelIds.forEach(channelId => {
        unsubscribe(`${redisPrefix}${channelId}`, listener);
      });

      stopHeartbeat();

      delete subscriptions[channelIds.join(';')];
    }).catch(err => {
      log.verbose(request.requestId, 'Unsubscription error:', err);
      socket.send(JSON.stringify({ error: err.toString() }));
    });

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
      listener,
      stopHeartbeat: () => {
      },
    };

    subscriptions[systemChannelId] = {
      listener,
      stopHeartbeat: () => {
      },
    };
  };

  /**
   * @param {string|string[]} arrayOrString
   * @return {string}
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

    /**
     * @type {WebSocketSession}
     */
    const session = {
      socket: ws,
      request: req,
      subscriptions: {},
    };

    const onEnd = () => {
      const keys = Object.keys(session.subscriptions);

      keys.forEach(channelIds => {
        const { listener, stopHeartbeat } = session.subscriptions[channelIds];

        channelIds.split(';').forEach(channelId => {
          unsubscribe(`${redisPrefix}${channelId}`, listener);
        });

        stopHeartbeat();
      });
    };

    ws.on('close', onEnd);
    ws.on('error', onEnd);

    ws.on('message', data => {
      const json = parseJSON(data, session.request);

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
    log.warn(`Worker ${workerId} now listening on ${address}`);
  });

  const onExit = () => {
    log.warn(`Worker ${workerId} exiting`);
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

/**
 * @param {function(Error=): void} onSuccess
 */
const onPortAvailable = onSuccess => {
  const testServer = http.createServer();

  testServer.once('error', err => {
    onSuccess(err);
  });

  testServer.once('listening', () => {
    testServer.once('close', () => onSuccess());
    testServer.close();
  });

  attachServerWithConfig(testServer);
};

onPortAvailable(err => {
  if (err) {
    log.error('Could not start server, the port or socket is in use');
    return;
  }

  throng({
    workers: numWorkers,
    lifetime: Infinity,
    start: startWorker,
    master: startMaster,
  });
});
