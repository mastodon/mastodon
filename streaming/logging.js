import { pino } from 'pino';
import { pinoHttp, stdSerializers as pinoHttpSerializers } from 'pino-http';
import * as uuid from 'uuid';

/**
 * Generates the Request ID for logging and setting on responses
 * @param {http.IncomingMessage} req
 * @param {http.ServerResponse} [res]
 * @returns {import("pino-http").ReqId}
 */
function generateRequestId(req, res) {
  if (req.id) {
    return req.id;
  }

  req.id = uuid.v4();

  // Allow for usage with WebSockets:
  if (res) {
    res.setHeader('X-Request-Id', req.id);
  }

  return req.id;
}

/**
 * Request log sanitizer to prevent logging access tokens in URLs
 * @param {http.IncomingMessage} req
 */
function sanitizeRequestLog(req) {
  const log = pinoHttpSerializers.req(req);
  if (typeof log.url === 'string' && log.url.includes('access_token')) {
    // Doorkeeper uses SecureRandom.urlsafe_base64 per RFC 6749 / RFC 6750
    log.url = log.url.replace(/(access_token)=([a-zA-Z0-9\-_]+)/gi, '$1=[Redacted]');
  }
  return log;
}

export const logger = pino({
  name: "streaming",
  // Reformat the log level to a string:
  formatters: {
    level: (label) => {
      return {
        level: label
      };
    },
  },
  redact: {
    paths: [
      'req.headers["sec-websocket-key"]',
      // Note: we currently pass the AccessToken via the websocket subprotocol
      // field, an anti-pattern, but this ensures it doesn't end up in logs.
      'req.headers["sec-websocket-protocol"]',
      'req.headers.authorization',
      'req.headers.cookie',
      'req.query.access_token'
    ]
  }
});

export const httpLogger = pinoHttp({
  logger,
  genReqId: generateRequestId,
  serializers: {
    req: sanitizeRequestLog
  }
});

/**
 * Attaches a logger to the request object received by http upgrade handlers
 * @param {http.IncomingMessage} request
 */
export function attachWebsocketHttpLogger(request) {
  generateRequestId(request);

  request.log = logger.child({
    req: sanitizeRequestLog(request),
  });
}

/**
 * Creates a logger instance for the Websocket connection to use.
 * @param {http.IncomingMessage} request
 * @param {import('./index.js').ResolvedAccount} resolvedAccount
 */
export function createWebsocketLogger(request, resolvedAccount) {
  // ensure the request.id is always present.
  generateRequestId(request);

  return logger.child({
    req: {
      id: request.id
    },
    account: {
      id: resolvedAccount.accountId ?? null
    }
  });
}

/**
 * Initializes the log level based on the environment
 * @param {Object<string, any>} env
 * @param {string} environment
 */
export function initializeLogLevel(env, environment) {
  if (env.LOG_LEVEL && Object.keys(logger.levels.values).includes(env.LOG_LEVEL)) {
    logger.level = env.LOG_LEVEL;
  } else if (environment === 'development') {
    logger.level = 'debug';
  } else {
    logger.level = 'info';
  }
}
