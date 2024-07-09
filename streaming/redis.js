import { Redis } from 'ioredis';

import { parseIntFromEnvValue } from './utils.js';

/**
 * @typedef RedisConfiguration
 * @property {import('ioredis').RedisOptions} redisParams
 * @property {string} redisPrefix
 * @property {string|undefined} redisUrl
 */

/**
 * @param {NodeJS.ProcessEnv} env the `process.env` value to read configuration from
 * @returns {RedisConfiguration} configuration for the Redis connection
 */
export function configFromEnv(env) {
  // ioredis *can* transparently add prefixes for us, but it doesn't *in some cases*,
  // which means we can't use it. But this is something that should be looked into.
  const redisPrefix = env.REDIS_NAMESPACE ? `${env.REDIS_NAMESPACE}:` : '';

  let redisPort = parseIntFromEnvValue(env.REDIS_PORT, 6379, 'REDIS_PORT');
  let redisDatabase = parseIntFromEnvValue(env.REDIS_DB, 0, 'REDIS_DB');

  /** @type {import('ioredis').RedisOptions} */
  const redisParams = {
    host: env.REDIS_HOST || '127.0.0.1',
    port: redisPort,
    // Force support for both IPv6 and IPv4, by default ioredis sets this to 4,
    // only allowing IPv4 connections:
    // https://github.com/redis/ioredis/issues/1576
    family: 0,
    db: redisDatabase,
    password: env.REDIS_PASSWORD || undefined,
  };

  // redisParams.path takes precedence over host and port.
  if (env.REDIS_URL && env.REDIS_URL.startsWith('unix://')) {
    redisParams.path = env.REDIS_URL.slice(7);
  }

  return {
    redisParams,
    redisPrefix,
    redisUrl: typeof env.REDIS_URL === 'string' ? env.REDIS_URL : undefined,
  };
}

/**
 * @param {RedisConfiguration} config
 * @param {import('pino').Logger} logger
 * @returns {Redis}
 */
export function createClient({ redisParams, redisUrl }, logger) {
  let client;

  if (typeof redisUrl === 'string') {
    client = new Redis(redisUrl, redisParams);
  } else {
    client = new Redis(redisParams);
  }

  client.on('error', (err) => logger.error({ err }, 'Redis Client Error!'));

  return client;
}
