import os from 'os';
import cluster from 'cluster';
import dotenv from 'dotenv';
import express from 'express';
import http from 'http';
import redis from 'redis';
import pg from 'pg';
import log from 'npmlog';
import url from 'url';
import WebSocket from 'uws';
import uuid from 'uuid';

const env = process.env.NODE_ENV || 'development';

dotenv.config({
  path: env === 'production' ? '.env.production' : '.env',
});

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

if (cluster.isMaster) {
  // Cluster master
  const core = +process.env.STREAMING_CLUSTER_NUM || (env === 'development' ? 1 : Math.max(os.cpus().length - 1, 1));

  const fork = () => {
    const worker = cluster.fork();

    worker.on('exit', (code, signal) => {
      log.error(`Worker died with exit code ${code}, signal ${signal} received.`);
      setTimeout(() => fork(), 0);
    });
  };

  for (let i = 0; i < core; i++) fork();

  log.info(`Starting streaming API server master with ${core} workers`);
} else {
  // Cluster worker
  const pgConfigs = {
    development: {
      database: 'mastodon_development',
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
  const wss    = new WebSocket.Server({ server });
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

  const redisClient = redisUrlToClient(redisParams, process.env.REDIS_URL);

  const subs = {};

  redisClient.on('pmessage', (_, channel, message) => {
    const callbacks = subs[channel];

    log.silly(`New message on channel ${channel}`);

    if (!callbacks) {
      return;
    }
    callbacks.forEach(callback => callback(message));
  });

  redisClient.psubscribe(`${redisPrefix}timeline:*`);

  const subscribe = (channel, callback) => {
    log.silly(`Adding listener for ${channel}`);
    subs[channel] = subs[channel] || [];
    subs[channel].push(callback);
  };

  const unsubscribe = (channel, callback) => {
    log.silly(`Removing listener for ${channel}`);
    subs[channel] = subs[channel].filter(item => item !== callback);
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

      client.query('SELECT oauth_access_tokens.resource_owner_id, users.account_id FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id WHERE oauth_access_tokens.token = $1 LIMIT 1', [token], (err, result) => {
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

        next();
      });
    });
  };

  const authenticationMiddleware = (req, res, next) => {
    if (req.method === 'OPTIONS') {
      next();
      return;
    }

    const authorization = req.get('Authorization');
    const accessToken = req.query.access_token;

    if (!authorization && !accessToken) {
      const err = new Error('Missing access token');
      err.statusCode = 401;

      next(err);
      return;
    }

    const token = authorization ? authorization.replace(/^Bearer /, '') : accessToken;

    accountFromToken(token, req, next);
  };

  const errorMiddleware = (err, req, res, next) => {
    log.error(req.requestId, err);
    res.writeHead(err.statusCode || 500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: err.statusCode ? `${err}` : 'An unexpected error occurred' }));
  };

  const placeholders = (arr, shift = 0) => arr.map((_, i) => `$${i + 1 + shift}`).join(', ');

  const streamFrom = (id, req, output, attachCloseHandler, needsFiltering = false) => {
    log.verbose(req.requestId, `Starting stream from ${id} for ${req.accountId}`);

    const listener = message => {
      const { event, payload, queued_at } = JSON.parse(message);

      const transmit = () => {
        const now   = new Date().getTime();
        const delta = now - queued_at;

        log.silly(req.requestId, `Transmitting for ${req.accountId}: ${event} ${payload} Delay: ${delta}ms`);
        output(event, payload);
      };

      // Only messages that may require filtering are statuses, since notifications
      // are already personalized and deletes do not matter
      if (needsFiltering && event === 'update') {
        pgPool.connect((err, client, done) => {
          if (err) {
            log.error(err);
            return;
          }

          const unpackedPayload  = JSON.parse(payload);
          const targetAccountIds = [unpackedPayload.account.id].concat(unpackedPayload.mentions.map(item => item.id)).concat(unpackedPayload.reblog ? [unpackedPayload.reblog.account.id] : []);
          const accountDomain    = unpackedPayload.account.acct.split('@')[1];

          const queries = [
            client.query(`SELECT 1 FROM blocks WHERE account_id = $1 AND target_account_id IN (${placeholders(targetAccountIds, 1)}) UNION SELECT 1 FROM mutes WHERE account_id = $1 AND target_account_id IN (${placeholders(targetAccountIds, 1)})`, [req.accountId].concat(targetAccountIds)),
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
  const streamHttpEnd = req => (id, listener) => {
    req.on('close', () => {
      unsubscribe(id, listener);
    });
  };

  // Setup stream output to WebSockets
  const streamToWs = (req, ws) => {
    const heartbeat = setInterval(() => {
      // TODO: Can't add multiple listeners, due to the limitation of uws.
      if (ws.readyState !== ws.OPEN) {
        log.verbose(req.requestId, `Ending stream for ${req.accountId}`);
        clearInterval(heartbeat);
        return;
      }

      ws.ping();
    }, 15000);

    return (event, payload) => {
      if (ws.readyState !== ws.OPEN) {
        log.error(req.requestId, 'Tried writing to closed socket');
        return;
      }

      ws.send(JSON.stringify({ event, payload }));
    };
  };

  // Setup stream end for WebSockets
  const streamWsEnd = ws => (id, listener) => {
    ws.on('close', () => {
      unsubscribe(id, listener);
    });

    ws.on('error', e => {
      unsubscribe(id, listener);
    });
  };

  app.use(setRequestId);
  app.use(allowCrossDomain);
  app.use(authenticationMiddleware);
  app.use(errorMiddleware);

  app.get('/api/v1/streaming/user', (req, res) => {
    streamFrom(`timeline:${req.accountId}`, req, streamToHttp(req, res), streamHttpEnd(req));
  });

  app.get('/api/v1/streaming/public', (req, res) => {
    streamFrom('timeline:public', req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/public/local', (req, res) => {
    streamFrom('timeline:public:local', req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/hashtag', (req, res) => {
    streamFrom(`timeline:hashtag:${req.query.tag}`, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  app.get('/api/v1/streaming/hashtag/local', (req, res) => {
    streamFrom(`timeline:hashtag:${req.query.tag}:local`, req, streamToHttp(req, res), streamHttpEnd(req), true);
  });

  wss.on('connection', ws => {
    const location = url.parse(ws.upgradeReq.url, true);
    const token    = location.query.access_token;
    const req      = { requestId: uuid.v4() };

    accountFromToken(token, req, err => {
      if (err) {
        log.error(req.requestId, err);
        ws.close();
        return;
      }

      switch(location.query.stream) {
      case 'user':
        streamFrom(`timeline:${req.accountId}`, req, streamToWs(req, ws), streamWsEnd(ws));
        break;
      case 'public':
        streamFrom('timeline:public', req, streamToWs(req, ws), streamWsEnd(ws), true);
        break;
      case 'public:local':
        streamFrom('timeline:public:local', req, streamToWs(req, ws), streamWsEnd(ws), true);
        break;
      case 'hashtag':
        streamFrom(`timeline:hashtag:${location.query.tag}`, req, streamToWs(req, ws), streamWsEnd(ws), true);
        break;
      case 'hashtag:local':
        streamFrom(`timeline:hashtag:${location.query.tag}:local`, req, streamToWs(req, ws), streamWsEnd(ws), true);
        break;
      default:
        ws.close();
      }
    });
  });

  server.listen(process.env.PORT || 4000, () => {
    log.level = process.env.LOG_LEVEL || 'verbose';
    log.info(`Starting streaming API server worker on ${server.address().address}:${server.address().port}`);
  });

  process.on('SIGINT', exit);
  process.on('SIGTERM', exit);
  process.on('exit', exit);

  function exit() {
    server.close();
  }
}
