import pg from 'pg';
import pgConnectionString from 'pg-connection-string';

import { parseIntFromEnvValue } from './utils.js';

/**
 * @param {NodeJS.ProcessEnv} env the `process.env` value to read configuration from
 * @param {string} environment
 * @returns {pg.PoolConfig} the configuration for the PostgreSQL connection
 */
export function configFromEnv(env, environment) {
  /** @type {Record<string, pg.PoolConfig>} */
  const pgConfigs = {
    development: {
      user: env.DB_USER || pg.defaults.user,
      password: env.DB_PASS || pg.defaults.password,
      database: env.DB_NAME || 'mastodon_development',
      host: env.DB_HOST || pg.defaults.host,
      port: parseIntFromEnvValue(env.DB_PORT, pg.defaults.port ?? 5432, 'DB_PORT')
    },

    production: {
      user: env.DB_USER || 'mastodon',
      password: env.DB_PASS || '',
      database: env.DB_NAME || 'mastodon_production',
      host: env.DB_HOST || 'localhost',
      port: parseIntFromEnvValue(env.DB_PORT, 5432, 'DB_PORT')
    },
  };

  /**
   * @type {pg.PoolConfig}
   */
  let baseConfig = {};

  if (env.DATABASE_URL) {
    const parsedUrl = pgConnectionString.parse(env.DATABASE_URL);

    // The result of dbUrlToConfig from pg-connection-string is not type
    // compatible with pg.PoolConfig, since parts of the connection URL may be
    // `null` when pg.PoolConfig expects `undefined`, as such we have to
    // manually create the baseConfig object from the properties of the
    // parsedUrl.
    //
    // For more information see:
    // https://github.com/brianc/node-postgres/issues/2280
    //
    // FIXME: clean up once brianc/node-postgres#3128 lands
    if (typeof parsedUrl.password === 'string') baseConfig.password = parsedUrl.password;
    if (typeof parsedUrl.host === 'string') baseConfig.host = parsedUrl.host;
    if (typeof parsedUrl.user === 'string') baseConfig.user = parsedUrl.user;
    if (typeof parsedUrl.port === 'string' && parsedUrl.port) {
      const parsedPort = parseInt(parsedUrl.port, 10);
      if (isNaN(parsedPort)) {
        throw new Error('Invalid port specified in DATABASE_URL environment variable');
      }
      baseConfig.port = parsedPort;
    }
    if (typeof parsedUrl.database === 'string') baseConfig.database = parsedUrl.database;
    if (typeof parsedUrl.options === 'string') baseConfig.options = parsedUrl.options;

    // The pg-connection-string type definition isn't correct, as parsedUrl.ssl
    // can absolutely be an Object, this is to work around these incorrect
    // types, including the casting of parsedUrl.ssl to Record<string, any>
    if (typeof parsedUrl.ssl === 'boolean') {
      baseConfig.ssl = parsedUrl.ssl;
    } else if (typeof parsedUrl.ssl === 'object' && !Array.isArray(parsedUrl.ssl) && parsedUrl.ssl !== null) {
      /** @type {Record<string, unknown>} */
      const sslOptions = parsedUrl.ssl;
      baseConfig.ssl = {};

      baseConfig.ssl.cert = sslOptions.cert;
      baseConfig.ssl.key = sslOptions.key;
      baseConfig.ssl.ca = sslOptions.ca;
      baseConfig.ssl.rejectUnauthorized = sslOptions.rejectUnauthorized;
    }

    // Support overriding the database password in the connection URL
    if (!baseConfig.password && env.DB_PASS) {
      baseConfig.password = env.DB_PASS;
    }
  } else if (Object.hasOwn(pgConfigs, environment)) {
    baseConfig = pgConfigs[environment];

    if (env.DB_SSLMODE) {
      switch(env.DB_SSLMODE) {
      case 'disable':
      case '':
        baseConfig.ssl = false;
        break;
      case 'no-verify':
        baseConfig.ssl = { rejectUnauthorized: false };
        break;
      default:
        baseConfig.ssl = {};
        break;
      }
    }
  } else {
    throw new Error('Unable to resolve postgresql database configuration.');
  }

  return {
    ...baseConfig,
    max: parseIntFromEnvValue(env.DB_POOL, 10, 'DB_POOL'),
    connectionTimeoutMillis: 15000,
    // Deliberately set application_name to an empty string to prevent excessive
    // CPU usage with PG Bouncer. See:
    // - https://github.com/mastodon/mastodon/pull/23958
    // - https://github.com/pgbouncer/pgbouncer/issues/349
    application_name: '',
  };
}

let pool;
/**
 *
 * @param {pg.PoolConfig} config
 * @param {string} environment
 * @param {import('pino').Logger} logger
 * @returns {pg.Pool}
 */
export function getPool(config, environment, logger) {
  if (pool) {
    return pool;
  }

  pool = new pg.Pool(config);

  // Setup logging on pool.query and client.query for checked out clients:
  // This is taken from: https://node-postgres.com/guides/project-structure
  if (environment === 'development') {
    const logQuery = (originalQuery) => {
      return async (queryTextOrConfig, values, ...rest) => {
        const start = process.hrtime();

        const result = await originalQuery.apply(pool, [queryTextOrConfig, values, ...rest]);

        const duration = process.hrtime(start);
        const durationInMs = (duration[0] * 1000000000 + duration[1]) / 1000000;

        logger.debug({
          query: queryTextOrConfig,
          values,
          duration: durationInMs
        }, 'Executed database query');

        return result;
      };
    };

    pool.on('connect', (client) => {
      const originalQuery = client.query.bind(client);
      client.query = logQuery(originalQuery);
    });
  }

  return pool;
}
