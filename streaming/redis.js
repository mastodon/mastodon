import { Redis } from 'ioredis';

import { parseIntFromEnvValue } from './utils.js';

/**
 * @typedef RedisConfiguration
 * @property {string|undefined} redisUrl
 * @property {import('ioredis').RedisOptions} redisOptions
 */

/**
 *
 * @param {NodeJS.ProcessEnv} env
 * @returns {boolean}
 */
function hasSentinelConfiguration(env) {
  return (
    typeof env.REDIS_SENTINELS === 'string' &&
    env.REDIS_SENTINELS.length > 0 &&
    typeof env.REDIS_SENTINEL_MASTER === 'string' &&
    env.REDIS_SENTINEL_MASTER.length > 0
  );
}

/**
 *
 * @param {NodeJS.ProcessEnv} env
 * @param {import('ioredis').SentinelConnectionOptions} commonOptions
 * @returns {import('ioredis').SentinelConnectionOptions}
 */
function getSentinelConfiguration(env, commonOptions) {
  const redisDatabase = parseIntFromEnvValue(env.REDIS_DB, 0, 'REDIS_DB');
  const sentinelPort = parseIntFromEnvValue(env.REDIS_SENTINEL_PORT, 26379, 'REDIS_SENTINEL_PORT');

  const sentinels = env.REDIS_SENTINELS.split(',').map((sentinel) => {
    const [host, port] = sentinel.split(':', 2);

    /** @type {import('ioredis').SentinelAddress} */
    return {
      host: host,
      port: port ?? sentinelPort,
      // Force support for both IPv6 and IPv4, by default ioredis sets this to 4,
      // only allowing IPv4 connections:
      // https://github.com/redis/ioredis/issues/1576
      family: 0
    };
  });

  return {
    db: redisDatabase,
    name: env.REDIS_SENTINEL_MASTER,
    username: env.REDIS_USERNAME,
    password: env.REDIS_PASSWORD,
    sentinelUsername: env.REDIS_SENTINEL_USERNAME ?? env.REDIS_USERNAME,
    sentinelPassword: env.REDIS_SENTINEL_PASSWORD ?? env.REDIS_PASSWORD,
    sentinels,
    ...commonOptions,
  };
}

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

  // If we have configuration for Redis Sentinel mode, prefer that:
  if (hasSentinelConfiguration(env)) {
    return {
      redisOptions: getSentinelConfiguration(env, commonOptions),
    };
  }

  // Finally, handle all the other REDIS_* environment variables:
  let redisPort = parseIntFromEnvValue(env.REDIS_PORT, 6379, 'REDIS_PORT');
  let redisDatabase = parseIntFromEnvValue(env.REDIS_DB, 0, 'REDIS_DB');

  /** @type {import('ioredis').RedisOptions} */
  const redisOptions = {
    host: env.REDIS_HOST ?? '127.0.0.1',
    port: redisPort,
    db: redisDatabase,
    username: env.REDIS_USERNAME,
    password: env.REDIS_PASSWORD,
    ...commonOptions,
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
