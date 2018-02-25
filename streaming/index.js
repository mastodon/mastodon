const os = require('os');
const throng = require('throng');
const dotenv = require('dotenv');
const express = require('express');
const http = require('http');
const redis = require('redis');
const pg = require('pg');
const log = require('npmlog');
const url = require('url');
const WebSocket = require('uws');
const uuid = require('uuid');

const env = process.env.NODE_ENV || 'development';

dotenv.config({
  path: env === 'production' ? '.env.production' : '.env',
});

log.level = process.env.LOG_LEVEL || 'verbose';

const dbUrlToConfig = (dbUrl) => {
  if (!dbUrl) {
    return {};
  }

  const params = url.parse(dbUrl);
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

  if (ssl) {
    config.ssl = ssl === 'true' || ssl === '1';
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
  log.info(`Starting streaming API server master with ${numWorkers} workers`);
};

const startWorker = (workerId) => {
  log.info(`Starting worker ${workerId}`);

  const pgConfigs = {
    development: {
      user:     process.env.DB_USER || pg.defaults.user,
      password: process.env.DB_PASS || pg.defaults.password,
      database: 'mastodon_development',
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

  const app    = express();
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

  const accountFromToken = (token, req, next) => {
    pgPool.connect((err, client, done) => {
      if (err) {
        next(err);
        return;
      }

      client.query('SELECT oauth_access_tokens.resource_owner_id, users.account_id, users.filtered_languages FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id WHERE oauth_access_tokens.token = $1 AND oauth_access_tokens.revoked_at IS NULL LIMIT 1', [token], (err, result) => {
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

        req.accountId = result.rows[0].account_id;
        req.filteredLanguages = result.rows[0].filtered_languages;

        next();
      });
    });
  };

  const accountFromRequest = (req, next) => {
    const authorization = req.headers.authorization;
    const location = url.parse(req.url, true);
    const accessToken = location.query.access_token;

    if (!authorization && !accessToken) {
      const err = new Error('Missing access token');
      err.statusCode = 401;

      next(err);
      return;
    }

    const token = authorization ? authorization.replace(/^Bearer /, '') : accessToken;

    accountFromToken(token, req, next);
  };

  const wsVerifyClient = (info, cb) => {
    accountFromRequest(info.req, err => {
      if (!err) {
        cb(true, undefined, undefined);
      } else {
        log.error(info.req.requestId, err.toString());
        cb(false, 401, 'Unauthorized');
      }
    });
  };

  const authenticationMiddleware = (req, res, next) => {
    if (req.method === 'OPTIONS') {
      next();
      return;
    }

    accountFromRequest(req, next);
  };

  const errorMiddleware = (err, req, res, {}) => {
    log.error(req.requestId, err.toString());
    res.writeHead(err.statusCode || 500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: err.statusCode ? err.toString() : 'An unexpected error occurred' }));
  };

  const placeholders = (arr, shift = 0) => arr.map((_, i) => `$${i + 1 + shift}`).join(', ');

  const streamFrom = (id, req, output, attachCloseHandler, needsFiltering = false, notificationOnly = false) => {
    const streamType = notificationOnly ? ' (notification)' : '';
    log.verbose(req.requestId, `Starting stream from ${id} for ${req.accountId}${streamType}`);

    const listener = message => {
      const { event, payload, queued_at } = JSON.parse(message);

      const transmit = () => {
        const now            = new Date().getTime();
        const delta          = now - queued_at;
        const encodedPayload = typeof payload === 'number' ? payload : JSON.stringify(payload);

        log.silly(req.requestId, `Transmitting for ${req.accountId}: ${event} ${encodedPayload} Delay: ${delta}ms`);
        output(event, encodedPayload);
      };

      if (notificationOnly && event !== 'notification') {
        return;
      }

      // Only messages that may require filtering are statuses, since notifications
      // are already personalized and deletes do not matter
      if (needsFiltering && event === 'update') {
        pgPool.connect((err, client, done) => {
          if (err) {
            log.error(err);
            return;
          }

          const unpackedPayload  = payload;
          const targetAccountIds = [unpackedPayload.account.id].concat(unpackedPayload.mentions.map(item => item.id));
          const accountDomain    = unpackedPayload.account.acct.split('@')[1];

          if (Array.isArray(req.filteredLanguages) && req.filteredLanguages.indexOf(unpackedPayload.language) !== -1) {
            log.silly(req.requestId, `Message ${unpackedPayload.id} filtered by language (${unpackedPayload.language})`);
            done();
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
      } else {
        transmit();
      }
    };

    subscribe(`${redisPrefix}${id}`, listener);
    attachCloseHandler(`${redisPrefix}${id}`, listener);
  };

  // Setup stream output to HTTP
  const streamToHttp = (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Transfer-Encoding', 'chunked');

    const heartbeat = setInterval(() => res.write(':thump\n'), 15000);

    req.on('close', () => {
      log.verbose(req.requestId, `Ending stream for ${req.accountId}`);
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
    ws.on('close', () => {
      log.verbose(req.requestId, `Ending stream for ${req.accountId}`);
      unsubscribe(id, listener);
      if (closeHandler) {
        closeHandler();
      }
    });

    ws.on('error', () => {
      log.verbose(req.requestId, `Ending stream for ${req.accountId}`);
      unsubscribe(id, listener);
      if (closeHandler) {
        closeHandler();
      }
    });
  };

  app.use(setRequestId);
  app.use(allowCrossDomain);
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
    streamFrom('timeline:public', req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/public/local', (req, res) => {
    streamFrom('timeline:public:local', req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/hashtag', (req, res) => {
    streamFrom(`timeline:hashtag:${req.query.tag.toLowerCase()}`, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/hashtag/local', (req, res) => {
    streamFrom(`timeline:hashtag:${req.query.tag.toLowerCase()}:local`, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  const wss    = new WebSocket.Server({ server, verifyClient: wsVerifyClient });

  wss.on('connection', ws => {
    const req      = ws.upgradeReq;
    const location = url.parse(req.url, true);
    req.requestId  = uuid.v4();

    ws.isAlive = true;

    ws.on('pong', () => {
      ws.isAlive = true;
    });

    switch(location.query.stream) {
    case 'user':
      const channel = `timeline:${req.accountId}`;
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
    case 'hashtag':
      streamFrom(`timeline:hashtag:${location.query.tag.toLowerCase()}`, req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    case 'hashtag:local':
      streamFrom(`timeline:hashtag:${location.query.tag.toLowerCase()}:local`, req, streamToWs(req, ws), streamWsEnd(req, ws), true);
      break;
    default:
      ws.close();
    }
  });

  setInterval(() => {
    wss.clients.forEach(ws => {
      if (ws.isAlive === false) {
        ws.terminate();
        return;
      }

      ws.isAlive = false;
      ws.ping('', false, true);
    });
  }, 30000);

  server.listen(process.env.PORT || 4000, () => {
    log.info(`Worker ${workerId} now listening on ${server.address().address}:${server.address().port}`);
  });

  const onExit = () => {
    log.info(`Worker ${workerId} exiting, bye bye`);
    server.close();
    process.exit(0);
  };

  const onError = (err) => {
    log.error(err);
  };

  process.on('SIGINT', onExit);
  process.on('SIGTERM', onExit);
  process.on('exit', onExit);
  process.on('error', onError);
};

throng({
  workers: numWorkers,
  lifetime: Infinity,
  start: startWorker,
  master: startMaster,
});
