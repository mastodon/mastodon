// Convenience function to load polyfills and return a promise when it's done.
// If there are no polyfills, then this is just Promise.resolve() which means
// it will execute in the same tick of the event loop (i.e. near-instant).

import { loadIntlPolyfills } from './intl';

function importExtraPolyfills() {
  return import(/* webpackChunkName: "extra_polyfills" */ './extra_polyfills');
}

export function loadPolyfills() {
  // Safari does not have requestIdleCallback.
  // This avoids shipping them all the polyfills.
  const needsExtraPolyfills = !window.requestIdleCallback;

  return Promise.all([
    loadIntlPolyfills(),
    // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- those properties might not exist in old browsers, even if they are always here in types
    needsExtraPolyfills && importExtraPolyfills(),
  ]);
}
