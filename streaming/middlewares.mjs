// @ts-check

import log from 'npmlog';
import * as uuid from 'uuid';

import { alwaysRequireAuth } from './constants.mjs';
import { checkScopes } from './utils.mjs';

/** @type {import('express').RequestHandler} */
export function allowCrossDomain(_req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Authorization, Accept, Cache-Control');
  res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');

  next();
}

/** @type {import('express').RequestHandler} */
export function authenticationMiddleware(req, res, next) {
  if (req.method === 'OPTIONS') {
    next();
    return;
  }

  accountFromRequest(req, alwaysRequireAuth)
    .then(() => checkScopes(req, channelNameFromPath(req)))
    .then(() => {
      subscribeHttpToSystemChannel(req, res);
    }).then(() => {
      next();
    }).catch(err => {
      next(err);
    });
}

/** @type {import('express').ErrorRequestHandler} */
export function errorMiddleware(err, req, res, next) {
  log.error(req.requestId, err.toString());

  if (res.headersSent) {
    next(err);
    return;
  }

  res.writeHead(err.status || 500, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: err.status ? err.toString() : 'An unexpected error occurred' }));
}

/** @type {import('express').RequestHandler} */
export function setRemoteAddress(req, _res, next) {
  req.remoteAddress = req.connection.remoteAddress;

  next();
}

/** @type {import('express').RequestHandler} */
export function setRequestId(req, res, next) {
  req.requestId = uuid.v4();
  res.header('X-Request-Id', req.requestId);

  next();
}
