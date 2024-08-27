import { Redis } from 'ioredis';

import { parseIntFromEnvValue } from './utils.js';

/**
 * @typedef RedisConfiguration
 * @property {string|undefined} redisUrl
 * @property {import('ioredis').RedisOptions} redisOptions
 */

/**
 * @param {NodeJS.ProcessEnv} env the `process.env` value to read configuration from
 * @returns {RedisConfiguration} configuration for the Redis connection
 */
export function configFromEnv(env) {
  const redisNamespace = env.REDIS_NAMESPACE ? `${env.REDIS_NAMESPACE}:` : undefined;

  // These options apply for both REDIS_URL based connections and connections
  // using the other REDIS_* environment variables:
  const commonOptions = {
    // Force support for both IPv6 and IPv4, by default ioredis sets this to 4,
    // only allowing IPv4 connections:
    // https://github.com/redis/ioredis/issues/1576
    family: 0,
    // Support auto-prefixing keys:
    keyPrefix: redisNamespace
  };

  // If we receive REDIS_URL, don't continue parsing any other REDIS_*
  // environment variables:
  if (typeof env.REDIS_URL === 'string' && env.REDIS_URL.length > 0) {
    return {
      redisUrl: env.REDIS_URL,
      redisOptions: commonOptions
    };
  }

  let redisPort = parseIntFromEnvValue(env.REDIS_PORT, 6379, 'REDIS_PORT');
  let redisDatabase = parseIntFromEnvValue(env.REDIS_DB, 0, 'REDIS_DB');

  /** @type {import('ioredis').RedisOptions} */
  const redisOptions = {
    host: env.REDIS_HOST ?? '127.0.0.1',
    port: redisPort,
    db: redisDatabase,
    password: env.REDIS_PASSWORD || undefined,
    ...commonOptions
  };

  return {
    redisOptions
  };
}

/**
 * @param {RedisConfiguration} config
 * @param {import('pino').Logger} logger
 * @returns {Redis}
 */
export function createClient({ redisUrl, redisOptions }, logger) {
  let client;

  if (typeof redisUrl === 'string') {
    client = new Redis(redisUrl, redisOptions);
  } else {
    client = new Redis(redisOptions);
  }

  client.on('error', (err) => logger.error({ err }, 'Redis Client Error!'));

  return client;
}
