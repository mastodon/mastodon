import pg from 'pg';
import pgConnectionString from 'pg-connection-string';
import { parseIntFromEnvValue } from './utils.js';

/**
 * Optimized PostgreSQL configuration setup
 * @param {NodeJS.ProcessEnv} env - The process environment
 * @param {string} environment - The environment to configure for
 * @returns {pg.PoolConfig} - The PostgreSQL connection configuration
 */
export function configFromEnv(env, environment) {
  const pgConfigs = {
    development: {
      user: env.DB_USER || pg.defaults.user,
      password: env.DB_PASS || pg.defaults.password,
      database: env.DB_NAME || 'mastodon_development',
      host: env.DB_HOST || pg.defaults.host,
      port: parseIntFromEnvValue(env.DB_PORT, pg.defaults.port || 5432, 'DB_PORT'),
    },
    production: {
      user: env.DB_USER || 'mastodon',
      password: env.DB_PASS || '',
      database: env.DB_NAME || 'mastodon_production',
      host: env.DB_HOST || 'localhost',
      port: parseIntFromEnvValue(env.DB_PORT, 5432, 'DB_PORT'),
    },
  };

  let baseConfig = {};

  if (env.DATABASE_URL) {
    const parsedUrl = pgConnectionString.parse(env.DATABASE_URL);

    baseConfig = {
      user: parsedUrl.user,
      password: parsedUrl.password,
      host: parsedUrl.host,
      port: parsedUrl.port ? parseInt(parsedUrl.port, 10) : undefined,
      database: parsedUrl.database,
      ssl: parseSslConfig(parsedUrl.ssl),
      options: parsedUrl.options,
    };

    // Override password if set in environment variables
    if (!baseConfig.password && env.DB_PASS) {
      baseConfig.password = env.DB_PASS;
    }
  } else if (pgConfigs[environment]) {
    baseConfig = { ...pgConfigs[environment] };
    setSslMode(env.DB_SSLMODE, baseConfig);
  } else {
    throw new Error('Unable to resolve PostgreSQL database configuration.');
  }

  return {
    ...baseConfig,
    max: parseIntFromEnvValue(env.DB_POOL, 10, 'DB_POOL'),
    connectionTimeoutMillis: 15000,
    application_name: '',
  };
}

/**
 * Helper to parse SSL configuration
 * @param {boolean | object} sslConfig
 * @returns {object | boolean} - SSL configuration
 */
function parseSslConfig(sslConfig) {
  if (typeof sslConfig === 'boolean') return sslConfig;
  if (typeof sslConfig === 'object' && sslConfig !== null) {
    return { cert: sslConfig.cert, key: sslConfig.key, ca: sslConfig.ca, rejectUnauthorized: sslConfig.rejectUnauthorized };
  }
  return undefined;
}

/**
 * Set SSL mode based on environment
 * @param {string} sslMode
 * @param {pg.PoolConfig} config
 */
function setSslMode(sslMode, config) {
  switch (sslMode) {
    case 'disable':
      config.ssl = false;
      break;
    case 'no-verify':
      config.ssl = { rejectUnauthorized: false };
      break;
    default:
      config.ssl = config.ssl || {};
  }
}

let pool;

/**
 * Get or create the PostgreSQL pool
 * @param {pg.PoolConfig} config - The configuration to use
 * @param {string} environment - The environment (development, production, etc.)
 * @param {import('pino').Logger} logger - Logger for query execution
 * @returns {pg.Pool} - The PostgreSQL pool
 */
export function getPool(config, environment, logger) {
  if (pool) return pool;

  pool = new pg.Pool(config);

  if (environment === 'development') {
    pool.on('connect', (client) => {
      const originalQuery = client.query.bind(client);
      client.query = logQuery(originalQuery, logger);
    });
  }

  return pool;
}

/**
 * Logs the database queries with execution duration
 * @param {Function} originalQuery
 * @param {import('pino').Logger} logger
 * @returns {Function}
 */
function logQuery(originalQuery, logger) {
  return async (queryTextOrConfig, values, ...rest) => {
    const start = process.hrtime();
    const result = await originalQuery(queryTextOrConfig, values, ...rest);
    const duration = process.hrtime(start);
    const durationInMs = (duration[0] * 1e9 + duration[1]) / 1e6;

    logger.debug({ query: queryTextOrConfig, values, duration: durationInMs }, 'Executed database query');
    return result;
  };
}
