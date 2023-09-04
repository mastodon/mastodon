// Convenience function to load polyfills and return a promise when it's done.
// If there are no polyfills, then this is just Promise.resolve() which means
// it will execute in the same tick of the event loop (i.e. near-instant).

function importBasePolyfills() {
  return import(/* webpackChunkName: "base_polyfills" */ './base_polyfills');
}

function importExtraPolyfills() {
  return import(/* webpackChunkName: "extra_polyfills" */ './extra_polyfills');
}

function loadPolyfills() {
  const needsBasePolyfills = !(
    Array.prototype.includes &&
    HTMLCanvasElement.prototype.toBlob &&
    window.Intl &&
    Number.isNaN &&
    Object.assign &&
    Object.values &&
    window.Symbol &&
    Promise.prototype.finally
  );

  // Latest version of Firefox and Safari do not have IntersectionObserver.
  // Edge does not have requestIdleCallback.
  // This avoids shipping them all the polyfills.
  const needsExtraPolyfills = !(
    window.AbortController &&
    window.IntersectionObserver &&
    window.IntersectionObserverEntry &&
    'isIntersecting' in IntersectionObserverEntry.prototype &&
    window.requestIdleCallback
  );

  return Promise.all([
    needsBasePolyfills && importBasePolyfills(),
    needsExtraPolyfills && importExtraPolyfills(),
  ]);
}

export default loadPolyfills;
