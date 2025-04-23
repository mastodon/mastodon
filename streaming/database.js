import pg from 'pg';
import { parse, toClientConfig } from 'pg-connection-string';

import { parseIntFromEnvValue } from './utils.js';

/**
 * @param {NodeJS.ProcessEnv} env the `process.env` value to read configuration from
 * @param {string} environment
 * @param {import('pino').Logger} logger
 * @returns {pg.PoolConfig} the configuration for the PostgreSQL connection
 */
export function configFromEnv(env, environment, logger) {
  /** @type {Record<string, pg.PoolConfig>} */
  const pgConfigs = {
    development: {
      user: env.DB_USER || pg.defaults.user,
      password: env.DB_PASS || pg.defaults.password,
      database: env.DB_NAME || 'mastodon_development',
      host: env.DB_HOST || pg.defaults.host,
      port: parseIntFromEnvValue(
        env.DB_PORT,
        pg.defaults.port ?? 5432,
        'DB_PORT',
      ),
    },

    production: {
      user: env.DB_USER || 'mastodon',
      password: env.DB_PASS || '',
      database: env.DB_NAME || 'mastodon_production',
      host: env.DB_HOST || 'localhost',
      port: parseIntFromEnvValue(env.DB_PORT, 5432, 'DB_PORT'),
    },
  };

  /**
   * @type {pg.PoolConfig}
   */
  let config = {};

  if (env.DATABASE_URL) {
    // parse will throw if both useLibpqCompat option is true and the
    // DATABASE_URL includes uselibpqcompat, so we're handling that case ahead
    // of time to give a more specific error message:
    if (env.DATABASE_URL.includes('uselibpqcompat')) {
      throw new Error(
        'SECURITY WARNING: Mastodon forces uselibpqcompat mode, do not include it in DATABASE_URL',
      );
    }

    config = toClientConfig(parse(env.DATABASE_URL, { useLibpqCompat: true }));
  } else if (Object.hasOwn(pgConfigs, environment)) {
    config = pgConfigs[environment];

    if (env.DB_SSLMODE) {
      logger.warn(
        'Using DB_SSLMODE is not recommended, instead use DATABASE_URL with SSL options',
      );

      switch (env.DB_SSLMODE) {
        case 'disable': {
          config.ssl = false;
          break;
        }
        case 'prefer': {
          config.ssl.rejectUnauthorized = false;
          break;
        }
        case 'require': {
          config.ssl.rejectUnauthorized = false;
          break;
        }
        case 'verify-ca': {
          throw new Error(
            'SECURITY WARNING: Using sslmode=verify-ca requires specifying a CA with sslrootcert. If a public CA is used, verify-ca allows connections to a server that somebody else may have registered with the CA, making you vulnerable to Man-in-the-Middle attacks. Either specify a custom CA certificate with sslrootcert parameter or use sslmode=verify-full for proper security. This can only be configured using DATABASE_URL.',
          );
        }
        case 'verify-full': {
          break;
        }
      }
    }
  } else {
    throw new Error('Unable to resolve postgresql database configuration.');
  }

  return {
    ...config,
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

        const result = await originalQuery.apply(pool, [
          queryTextOrConfig,
          values,
          ...rest,
        ]);

        const duration = process.hrtime(start);
        const durationInMs = (duration[0] * 1000000000 + duration[1]) / 1000000;

        logger.debug(
          {
            query: queryTextOrConfig,
            values,
            duration: durationInMs,
          },
          'Executed database query',
        );

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
