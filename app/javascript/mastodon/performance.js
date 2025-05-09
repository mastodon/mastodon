//
// Tools for performance debugging, only enabled in development mode.
// Open up Chrome Dev Tools, then Timeline, then User Timing to see output.

import * as marky from 'marky';

import { isDevelopment } from './utils/environment';

export function start(name) {
  if (isDevelopment()) {
    marky.mark(name);
  }
}

export function stop(name) {
  if (isDevelopment()) {
    marky.stop(name);
  }
}
