// @ts-check

import * as os from 'node:os';

/** @type {boolean} */
export const alwaysRequireAuth =
  process.env.LIMITED_FEDERATION_MODE === 'true' ||
  process.env.WHITELIST_MODE === 'true' ||
  process.env.AUTHORIZED_FETCH === 'true';

/** @type {string} */
export const env = process.env.NODE_ENV || 'development';

/** @type {string} */
export const logLevel = process.env.LOG_LEVEL || 'verbose';

/** @type {number} */
export const numWorkers =
  +process.env.STREAMING_CLUSTER_NUM ||
  (env === 'development' ? 1 : Math.max(os.cpus().length - 1, 1));

/** @type {string} */
export const redisNamespace = process.env.REDIS_NAMESPACE || null;

export const trustedProxyIp = process.env.TRUSTED_PROXY_IP
  ? process.env.TRUSTED_PROXY_IP.split(/(?:\s*,\s*|\s+)/)
  : 'loopback,uniquelocal';
