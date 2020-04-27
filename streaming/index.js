const os = require('os');
const throng = require('throng');
const dotenv = require('dotenv');
const express = require('express');
const http = require('http');
const redis = require('redis');
const pg = require('pg');
const log = require('npmlog');
const url = require('url');
const { WebSocketServer } = require('@clusterws/cws');
const uuid = require('uuid');
const fs = require('fs');

const env = process.env.NODE_ENV || 'development';
const alwaysRequireAuth = process.env.WHITELIST_MODE === 'true' || process.env.AUTHORIZED_FETCH === 'true';

dotenv.config({
  path: env === 'production' ? '.env.production' : '.env',
});

log.level = process.env.LOG_LEVEL || 'verbose';

const dbUrlToConfig = (dbUrl) => {
  if (!dbUrl) {
    return {};
  }

  const params = url.parse(dbUrl, true);
  const config = {};

  if (params.auth) {
    [config.user, config.password] = params.auth.split(':');
  }

  if (params.hostname) {
    config.host = params.hostname;
  }

  if (params.port) {
    config.port = params.port;
  }

  if (params.pathname) {
    config.database = params.pathname.split('/')[1];
  }

  const ssl = params.query && params.query.ssl;

  if (ssl && ssl === 'true' || ssl === '1') {
    config.ssl = true;
  }

  return config;
};

const redisUrlToClient = (defaultConfig, redisUrl) => {
  const config = defaultConfig;

  if (!redisUrl) {
    return redis.createClient(config);
  }

  if (redisUrl.startsWith('unix://')) {
    return redis.createClient(redisUrl.slice(7), config);
  }

  return redis.createClient(Object.assign(config, {
    url: redisUrl,
  }));
};

const numWorkers = +process.env.STREAMING_CLUSTER_NUM || (env === 'development' ? 1 : Math.max(os.cpus().length - 1, 1));

const startMaster = () => {
  if (!process.env.SOCKET && process.env.PORT && isNaN(+process.env.PORT)) {
    log.warn('UNIX domain socket is now supported by using SOCKET. Please migrate from PORT hack.');
  }

  log.info(`Starting streaming API server master with ${numWorkers} workers`);
};

const startWorker = (workerId) => {
  log.info(`Starting worker ${workerId}`);

  const pgConfigs = {
    development: {
      user:     process.env.DB_USER || pg.defaults.user,
      password: process.env.DB_PASS || pg.defaults.password,
      database: process.env.DB_NAME || 'mastodon_development',
      host:     process.env.DB_HOST || pg.defaults.host,
      port:     process.env.DB_PORT || pg.defaults.port,
      max:      10,
    },

    production: {
      user:     process.env.DB_USER || 'mastodon',
      password: process.env.DB_PASS || '',
      database: process.env.DB_NAME || 'mastodon_production',
      host:     process.env.DB_HOST || 'localhost',
      port:     process.env.DB_PORT || 5432,
      max:      10,
    },
  };

  if (!!process.env.DB_SSLMODE && process.env.DB_SSLMODE !== 'disable') {
    pgConfigs.development.ssl = true;
    pgConfigs.production.ssl  = true;
  }

  const app = express();
  app.set('trusted proxy', process.env.TRUSTED_PROXY_IP || 'loopback,uniquelocal');

  const pgPool = new pg.Pool(Object.assign(pgConfigs[env], dbUrlToConfig(process.env.DATABASE_URL)));
  const server = http.createServer(app);
  const redisNamespace = process.env.REDIS_NAMESPACE || null;

  const redisParams = {
    host:     process.env.REDIS_HOST     || '127.0.0.1',
    port:     process.env.REDIS_PORT     || 6379,
    db:       process.env.REDIS_DB       || 0,
    password: process.env.REDIS_PASSWORD,
  };

  if (redisNamespace) {
    redisParams.namespace = redisNamespace;
  }

  const redisPrefix = redisNamespace ? `${redisNamespace}:` : '';

  const redisSubscribeClient = redisUrlToClient(redisParams, process.env.REDIS_URL);
  const redisClient = redisUrlToClient(redisParams, process.env.REDIS_URL);

  const subs = {};

  redisSubscribeClient.on('message', (channel, message) => {
    const callbacks = subs[channel];

    log.silly(`New message on channel ${channel}`);

    if (!callbacks) {
      return;
    }

    callbacks.forEach(callback => callback(message));
  });

  const subscriptionHeartbeat = (channel) => {
    const interval = 6*60;
    const tellSubscribed = () => {
      redisClient.set(`${redisPrefix}subscribed:${channel}`, '1', 'EX', interval*3);
    };
    tellSubscribed();
    const heartbeat = setInterval(tellSubscribed, interval*1000);
    return () => {
      clearInterval(heartbeat);
    };
  };

  const subscribe = (channel, callback) => {
    log.silly(`Adding listener for ${channel}`);
    subs[channel] = subs[channel] || [];
    if (subs[channel].length === 0) {
      log.verbose(`Subscribe ${channel}`);
      redisSubscribeClient.subscribe(channel);
    }
    subs[channel].push(callback);
  };

  const unsubscribe = (channel, callback) => {
    log.silly(`Removing listener for ${channel}`);
    subs[channel] = subs[channel].filter(item => item !== callback);
    if (subs[channel].length === 0) {
      log.verbose(`Unsubscribe ${channel}`);
      redisSubscribeClient.unsubscribe(channel);
    }
  };

  const allowCrossDomain = (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Authorization, Accept, Cache-Control');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');

    next();
  };

  const setRequestId = (req, res, next) => {
    req.requestId = uuid.v4();
    res.header('X-Request-Id', req.requestId);

    next();
  };

  const setRemoteAddress = (req, res, next) => {
    req.remoteAddress = req.connection.remoteAddress;

    next();
  };

  const accountFromToken = (token, allowedScopes, req, next) => {
    pgPool.connect((err, client, done) => {
      if (err) {
        next(err);
        return;
      }

      client.query('SELECT oauth_access_tokens.resource_owner_id, users.account_id, users.chosen_languages, oauth_access_tokens.scopes FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id WHERE oauth_access_tokens.token = $1 AND oauth_access_tokens.revoked_at IS NULL LIMIT 1', [token], (err, result) => {
        done();

        if (err) {
          next(err);
          return;
        }

        if (result.rows.length === 0) {
          err = new Error('Invalid access token');
          err.statusCode = 401;

          next(err);
          return;
        }

        const scopes = result.rows[0].scopes.split(' ');

        if (allowedScopes.size > 0 && !scopes.some(scope => allowedScopes.includes(scope))) {
          err = new Error('Access token does not cover required scopes');
          err.statusCode = 401;

          next(err);
          return;
        }

        req.accountId = result.rows[0].account_id;
        req.chosenLanguages = result.rows[0].chosen_languages;
        req.allowNotifications = scopes.some(scope => ['read', 'read:notifications'].includes(scope));

        next();
      });
    });
  };

  const accountFromRequest = (req, next, required = true, allowedScopes = ['read']) => {
    const authorization = req.headers.authorization;
    const location = url.parse(req.url, true);
    const accessToken = location.query.access_token || req.headers['sec-websocket-protocol'];

    if (!authorization && !accessToken) {
      if (required) {
        const err = new Error('Missing access token');
        err.statusCode = 401;

        next(err);
        return;
      } else {
        next();
        return;
      }
    }

    const token = authorization ? authorization.replace(/^Bearer /, '') : accessToken;

    accountFromToken(token, allowedScopes, req, next);
  };

  const PUBLIC_STREAMS = [
    'public',
    'public:media',
    'public:local',
    'public:local:media',
    'hashtag',
    'hashtag:local',
  ];

  const wsVerifyClient = (info, cb) => {
    const location = url.parse(info.req.url, true);
    const authRequired = alwaysRequireAuth || !PUBLIC_STREAMS.some(stream => stream === location.query.stream);
    const allowedScopes = [];

    if (authRequired) {
      allowedScopes.push('read');
      if (location.query.stream === 'user:notification') {
        allowedScopes.push('read:notifications');
      } else {
        allowedScopes.push('read:statuses');
      }
    }

    accountFromRequest(info.req, err => {
      if (!err) {
        cb(true, undefined, undefined);
      } else {
        log.error(info.req.requestId, err.toString());
        cb(false, 401, 'Unauthorized');
      }
    }, authRequired, allowedScopes);
  };

  const PUBLIC_ENDPOINTS = [
    '/api/v1/streaming/public',
    '/api/v1/streaming/public/local',
    '/api/v1/streaming/hashtag',
    '/api/v1/streaming/hashtag/local',
  ];

  const authenticationMiddleware = (req, res, next) => {
    if (req.method === 'OPTIONS') {
      next();
      return;
    }

    const authRequired = alwaysRequireAuth || !PUBLIC_ENDPOINTS.some(endpoint => endpoint === req.path);
    const allowedScopes = [];

    if (authRequired) {
      allowedScopes.push('read');
      if (req.path === '/api/v1/streaming/user/notification') {
        allowedScopes.push('read:notifications');
      } else {
        allowedScopes.push('read:statuses');
      }
    }

    accountFromRequest(req, next, authRequired, allowedScopes);
  };

  const errorMiddleware = (err, req, res, {}) => {
    log.error(req.requestId, err.toString());
    res.writeHead(err.statusCode || 500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: err.statusCode ? err.toString() : 'An unexpected error occurred' }));
  };

  const placeholders = (arr, shift = 0) => arr.map((_, i) => `$${i + 1 + shift}`).join(', ');

  const authorizeListAccess = (id, req, next) => {
    pgPool.connect((err, client, done) => {
      if (err) {
        next(false);
        return;
      }

      client.query('SELECT id, account_id FROM lists WHERE id = $1 LIMIT 1', [id], (err, result) => {
        done();

        if (err || result.rows.length === 0 || result.rows[0].account_id !== req.accountId) {
          next(false);
          return;
        }

        next(true);
      });
    });
  };

  const streamFrom = (id, req, output, attachCloseHandler, needsFiltering = false, notificationOnly = false) => {
    const accountId = req.accountId || req.remoteAddress;

    const streamType = notificationOnly ? ' (notification)' : '';
    log.verbose(req.requestId, `Starting stream from ${id} for ${accountId}${streamType}`);

    const listener = message => {
      const { event, payload, queued_at } = JSON.parse(message);

      const transmit = () => {
        const now            = new Date().getTime();
        const delta          = now - queued_at;
        const encodedPayload = typeof payload === 'object' ? JSON.stringify(payload) : payload;

        log.silly(req.requestId, `Transmitting for ${accountId}: ${event} ${encodedPayload} Delay: ${delta}ms`);
        output(event, encodedPayload);
      };

      if (notificationOnly && event !== 'notification') {
        return;
      }

      if (event === 'notification' && !req.allowNotifications) {
        return;
      }

      // Only messages that may require filtering are statuses, since notifications
      // are already personalized and deletes do not matter
      if (!needsFiltering || event !== 'update') {
        transmit();
        return;
      }

      const unpackedPayload  = payload;
      const targetAccountIds = [unpackedPayload.account.id].concat(unpackedPayload.mentions.map(item => item.id));
      const accountDomain    = unpackedPayload.account.acct.split('@')[1];

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
          client.query(`SELECT 1 FROM blocks WHERE (account_id = $1 AND target_account_id IN (${placeholders(targetAccountIds, 2)})) OR (account_id = $2 AND target_account_id = $1) UNION SELECT 1 FROM mutes WHERE account_id = $1 AND target_account_id IN (${placeholders(targetAccountIds, 2)})`, [req.accountId, unpackedPayload.account.id].concat(targetAccountIds)),
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

    subscribe(`${redisPrefix}${id}`, listener);
    attachCloseHandler(`${redisPrefix}${id}`, listener);
  };

  // Setup stream output to HTTP
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

  // Setup stream end for HTTP
  const streamHttpEnd = (req, closeHandler = false) => (id, listener) => {
    req.on('close', () => {
      unsubscribe(id, listener);
      if (closeHandler) {
        closeHandler();
      }
    });
  };

  // Setup stream output to WebSockets
  const streamToWs = (req, ws) => (event, payload) => {
    if (ws.readyState !== ws.OPEN) {
      log.error(req.requestId, 'Tried writing to closed socket');
      return;
    }

    ws.send(JSON.stringify({ event, payload }));
  };

  // Setup stream end for WebSockets
  const streamWsEnd = (req, ws, closeHandler = false) => (id, listener) => {
    const accountId = req.accountId || req.remoteAddress;

    ws.on('close', () => {
      log.verbose(req.requestId, `Ending stream for ${accountId}`);
      unsubscribe(id, listener);
      if (closeHandler) {
        closeHandler();
      }
    });

    ws.on('error', () => {
      log.verbose(req.requestId, `Ending stream for ${accountId}`);
      unsubscribe(id, listener);
      if (closeHandler) {
        closeHandler();
      }
    });
  };

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

  app.use(authenticationMiddleware);
  app.use(errorMiddleware);

  app.get('/api/v1/streaming/user', (req, res) => {
    const channel = `timeline:${req.accountId}`;
    streamFrom(channel, req, streamToHttp(req, res), streamHttpEnd(req, subscriptionHeartbeat(channel)));
  });

  app.get('/api/v1/streaming/user/notification', (req, res) => {
    streamFrom(`timeline:${req.accountId}`, req, streamToHttp(req, res), streamHttpEnd(req), false, true);
  });

  app.get('/api/v1/streaming/public', (req, res) => {
    const onlyMedia = req.query.only_media === '1' || req.query.only_media === 'true';
    const channel   = onlyMedia ? 'timeline:public:media' : 'timeline:public';

    streamFrom(channel, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/public/local', (req, res) => {
    const onlyMedia = req.query.only_media === '1' || req.query.only_media === 'true';
    const channel   = onlyMedia ? 'timeline:public:local:media' : 'timeline:public:local';

    streamFrom(channel, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/direct', (req, res) => {
    const channel = `timeline:direct:${req.accountId}`;
    streamFrom(channel, req, streamToHttp(req, res), streamHttpEnd(req, subscriptionHeartbeat(channel)), true);
  });

  app.get('/api/v1/streaming/hashtag', (req, res) => {
    const { tag } = req.query;

    if (!tag || tag.length === 0) {
      httpNotFound(res);
      return;
    }

    streamFrom(`timeline:hashtag:${tag.toLowerCase()}`, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/hashtag/local', (req, res) => {
    const { tag } = req.query;

    if (!tag || tag.length === 0) {
      httpNotFound(res);
      return;
    }

    streamFrom(`timeline:hashtag:${tag.toLowerCase()}:local`, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/list', (req, res) => {
    const listId = req.query.list;

    authorizeListAccess(listId, req, authorized => {
      if (!authorized) {
        httpNotFound(res);
        return;
      }

      const channel = `timeline:list:${listId}`;
      streamFrom(channel, req, streamToHttp(req, res), streamHttpEnd(req, subscriptionHeartbeat(channel)));
    });
  });

  const wss = new WebSocketServer({ server, verifyClient: wsVerifyClient });

  wss.on('connection', (ws, req) => {
    const location = url.parse(req.url, true);
    req.requestId  = uuid.v4();
    req.remoteAddress = ws._socket.remoteAddress;

    let channel;

    switch(location.query.stream) {
    case 'user':
      channel = `timeline:${req.accountId}`;
      streamFrom(channel, req, streamToWs(req, ws), streamWsEnd(req, ws, subscriptionHeartbeat(channel)));
      break;
    case 'user:notification':
      streamFrom(`timeline:${req.accountId}`, req, streamToWs(req, ws), streamWsEnd(req, ws), false, true);
      break;
    case 'public':
      streamFrom('timeline:public', req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    case 'public:local':
      streamFrom('timeline:public:local', req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    case 'public:media':
      streamFrom('timeline:public:media', req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    case 'public:local:media':
      streamFrom('timeline:public:local:media', req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    case 'direct':
      channel = `timeline:direct:${req.accountId}`;
      streamFrom(channel, req, streamToWs(req, ws), streamWsEnd(req, ws, subscriptionHeartbeat(channel)), true);
      break;
    case 'hashtag':
      if (!location.query.tag || location.query.tag.length === 0) {
        ws.close();
        return;
      }

      streamFrom(`timeline:hashtag:${location.query.tag.toLowerCase()}`, req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    case 'hashtag:local':
      if (!location.query.tag || location.query.tag.length === 0) {
        ws.close();
        return;
      }

      streamFrom(`timeline:hashtag:${location.query.tag.toLowerCase()}:local`, req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    case 'list':
      const listId = location.query.list;

      authorizeListAccess(listId, req, authorized => {
        if (!authorized) {
          ws.close();
          return;
        }

        channel = `timeline:list:${listId}`;
        streamFrom(channel, req, streamToWs(req, ws), streamWsEnd(req, ws, subscriptionHeartbeat(channel)));
      });
      break;
    default:
      ws.close();
    }
  });

  wss.startAutoPing(30000);

  attachServerWithConfig(server, address => {
    log.info(`Worker ${workerId} now listening on ${address}`);
  });

  const onExit = () => {
    log.info(`Worker ${workerId} exiting, bye bye`);
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
