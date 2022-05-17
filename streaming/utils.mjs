// @ts-check

import * as fs from 'node:fs';
import * as http from 'node:http';

import log from 'npmlog';
import * as redis from 'redis';

const LOG_PREFIX = 'utils';

/**
 * @param {http.Server} server
 * @param {((address: string) => void)=} onSuccess
 * @returns {void}
 */
export function attachServerWithConfig(server, onSuccess) {
  if (process.env.SOCKET || process.env.PORT && isNaN(+process.env.PORT)) {
    server.listen(process.env.SOCKET || process.env.PORT, () => {
      if (!onSuccess) return;

      fs.chmodSync(server.address(), 0o666);
      onSuccess(server.address());
    });
  } else {
    server.listen(+process.env.PORT || 4000, process.env.BIND || '127.0.0.1', () => {
      if (onSuccess) {
        onSuccess(`${server.address().address}:${server.address().port}`);
      }
    });
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
 * @param {import('express').Request} req
 * @param {string} channelName
 * @return {Promise<void>}
 */
export function checkScopes(req, channelName) {
  return new Promise((resolve, reject) => {
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
}

/**
 * @param {string} dbUrl
 * @return {import('pg').PoolConfig}
 */
export function dbUrlToConfig(dbUrl) {
  if (!dbUrl) {
    return {};
  }

  const url = new URL(dbUrl);
  /** @type {import('pg').PoolConfig} */
  const config = {};

  if (url.username) {
    config.user = url.username;
  }

  if (url.password) {
    config.password = url.password;
  }

  if (url.hostname) {
    config.host = url.hostname;
  }

  if (url.port) {
    config.port = +url.port;
  }

  if (url.pathname) {
    config.database = url.pathname.split('/')[1];
  }

  if (url.searchParams.has('ssl')) {
    config.ssl = isTruthy(url.searchParams.get('ssl'));
  }

  return config;
}

/**
 * @param {string | string[]} arrayOrString
 * @returns {string}
 */
export function firstParam(arrayOrString) {
  return Array.isArray(arrayOrString) ? arrayOrString[0] : arrayOrString;
}

/**
 * @param {import('express').Response} res
 * @returns {void}
 */
export function httpNotFound(res) {
  res.status(404).json({
    error: 'Not found',
  });
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
 * @param {import('express').Request} req
 * @param {string[]} necessaryScopes
 * @returns {boolean}
 */
export function isInScope(req, necessaryScopes) {
  return req.scopes.some(scope => necessaryScopes.includes(scope));
}

/**
 * @param {boolean | number | string} value
 * @return {boolean}
 */
export function isTruthy(value) {
  return value && !FALSE_VALUES.includes(value);
}

/**
 * @param {((err?: Error) => void)=} onSuccess
 * @returns {void}
 */
export function onPortAvailable(onSuccess) {
  const testServer = http.createServer();

  testServer.once('error', err => {
    onSuccess(err);
  });

  testServer.once('listening', () => {
    testServer.once('close', () => onSuccess());
    testServer.close();
  });

  attachServerWithConfig(testServer);
}

/**
 * @param {string} json
 * @param {Express.Request} req
 * @returns {object | null}
 */
export function parseJSON(json, req) {
  try {
    return JSON.parse(json);
  } catch (err) {
    if (req.accountId) {
      log.warn(req.requestId, `Error parsing message from user ${req.accountId}:`, err);
    } else {
      log.silly(req.requestId, `Error parsing message from ${req.remoteAddress}:`, err);
    }
  }

  return null;
}

/**
 * @param {string[]} values
 * @param {number=} shift
 * @return {string}
 */
export function placeholders(values, shift = 0) {
  return values.map((_, i) => `$${i + 1 + shift}`).join(', ');
}

/**
 * @param {redis.RedisClientOptions} defaultConfig
 * @param {string} redisUrl
 * @returns {Promise<redis.RedisClientType>}
 */
export async function redisUrlToClient(defaultConfig, redisUrl) {
  /** @type {redis.RedisClientType} */
  let client;

  if (!redisUrl) {
    client = redis.createClient(defaultConfig);
  } else if (redisUrl.startsWith('unix://')) {
    client = redis.createClient({
      ...defaultConfig,
      socket: {
        path: redisUrl.slice(7),
      },
    });
  } else {
    client = redis.createClient({
      ...defaultConfig,
      url: redisUrl,
    });
  }

  client.on('error', (err) => {
    log.error(LOG_PREFIX, 'Redis Client Error!', err);
  });
  await client.connect();

  return client;
}

/**
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 */
export function subscribeHttpToSystemChannel(req, res) {
  const systemChannelId = `timeline:access_token:${req.accessTokenId}`;

  const listener = createSystemMessageListener(req, {
    onKill() {
      res.end();
    },
  });

  res.on('close', () => {
    unsubscribe(`${redisPrefix}${systemChannelId}`, listener);
  });

  subscribe(`${redisPrefix}${systemChannelId}`, listener);
}
