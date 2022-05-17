// @ts-check

import * as http from 'node:http';
import * as url from 'node:url';

import * as dotenv from 'dotenv';
import express from 'express';
import log from 'npmlog';
import * as pg from 'pg';
import throng from 'throng';
import * as uuid from 'uuid';
import WebSocket from 'ws';

import {
  alwaysRequireAuth,
  env,
  logLevel,
  numWorkers,
  redisNamespace,
  trustedProxyIp,
} from './constants.mjs';
import {
  allowCrossDomain,
  authenticationMiddleware,
  errorMiddleware,
  setRemoteAddress,
  setRequestId,
} from './middlewares.mjs';
import Subscriber from './subscriber.mjs';
import {
  attachServerWithConfig,
  checkScopes,
  dbUrlToConfig,
  firstParam,
  httpNotFound,
  isInScope,
  isTruthy,
  onPortAvailable,
  parseJSON,
  placeholders,
  redisUrlToClient,
} from './utils.mjs';

dotenv.config({
  path: env === 'production' ? '.env.production' : '.env',
});

log.level = logLevel;

const startMaster = () => {
  if (!process.env.SOCKET && process.env.PORT && isNaN(+process.env.PORT)) {
    log.warn('UNIX domain socket is now supported by using SOCKET. Please migrate from PORT hack.');
  }

  log.warn(`Starting streaming API server master with ${numWorkers} workers`);
};

const startWorker = async (workerId) => {
  log.warn(`Starting worker ${workerId}`);

  /** @type {Record<string, pg.PoolConfig>} */
  const pgConfigs = {
    development: {
      user:     process.env.DB_USER || pg.defaults.user,
      password: process.env.DB_PASS || pg.defaults.password,
      database: process.env.DB_NAME || 'mastodon_development',
      host:     process.env.DB_HOST || pg.defaults.host,
      port:     process.env.DB_PORT ? +process.env.DB_PORT : pg.defaults.port,
      max:      10,
    },

    production: {
      user:     process.env.DB_USER || 'mastodon',
      password: process.env.DB_PASS || '',
      database: process.env.DB_NAME || 'mastodon_production',
      host:     process.env.DB_HOST || 'localhost',
      port:     process.env.DB_PORT ? +process.env.DB_PORT : 5432,
      max:      10,
    },
  };

  if (!!process.env.DB_SSLMODE && process.env.DB_SSLMODE !== 'disable') {
    pgConfigs.development.ssl = true;
    pgConfigs.production.ssl = true;
  }

  const app = express();

  app.set('trust proxy', trustedProxyIp);

  const pgPool = new pg.Pool({
    ...pgConfigs[env],
    ...dbUrlToConfig(process.env.DATABASE_URL),
  });
  const server = http.createServer(app);

  /** @type {import('redis').RedisClientOptions} */
  const redisParams = {
    socket: {
      host: process.env.REDIS_HOST || '127.0.0.1',
      port: process.env.REDIS_PORT ? +process.env.REDIS_PORT : 6379,
    },
    database: process.env.REDIS_DB ? +process.env.REDIS_DB : 0,
    password: process.env.REDIS_PASSWORD || undefined,
  };

  const redisPrefix = redisNamespace ? `${redisNamespace}:` : '';

  const redisSubscribeClient = await redisUrlToClient(redisParams, process.env.REDIS_URL);
  const redisClient = await redisUrlToClient(redisParams, process.env.REDIS_URL);
  const subscriber = new Subscriber({
    redisClient: redisSubscribeClient,
  });

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
      }
    };
  };

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

        Promise.all(queries).then(values => {
          done();

          if (values[0].rows.length > 0 || (values.length > 1 && values[1].rows.length > 0)) {
            return;
          }

          transmit();
        }).catch(err => {
          done();
          log.error(err);
        });
      });
    };

    ids.forEach(id => {
      subscriber.register(`${redisPrefix}${id}`, listener);
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
        subscriber.unregister(id);
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

  app.use(setRequestId);
  app.use(setRemoteAddress);
  app.use(allowCrossDomain);

  app.get('/api/v1/streaming/health', (req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('OK');
  });

  app.use(authenticationMiddleware);
  app.use(errorMiddleware);

  app.get('/api/v1/streaming/*', (req, res) => {
    channelNameToIds(req, channelNameFromPath(req), req.query)
      .then(({ channelIds, options }) => {
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
          channelIds: [`timeline:hashtag:${params.tag.toLowerCase()}`],
          options: { needsFiltering: true },
        });
      }

      break;
    case 'hashtag:local':
      if (!params.tag || params.tag.length === 0) {
        reject('No tag for stream provided');
      } else {
        resolve({
          channelIds: [`timeline:hashtag:${params.tag.toLowerCase()}:local`],
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
        subscriber.unregister(`${redisPrefix}${channelId}`, listener);
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
    const systemChannelId = `timeline:access_token:${request.accessTokenId}`;

    const listener = createSystemMessageListener(request, {

      onKill() {
        socket.close();
      },

    });

    subscriber.register(`${redisPrefix}${systemChannelId}`, listener);

    subscriptions[systemChannelId] = {
      listener,
      stopHeartbeat: () => {
      },
    };
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
          subscriber.unregister(`${redisPrefix}${channelId}`, listener);
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
