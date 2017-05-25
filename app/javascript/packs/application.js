import main from '../mastodon/main';

const needsBasePolyfills = !(
  window.Intl &&
  Object.assign &&
  Number.isNaN &&
  window.Symbol &&
  Array.prototype.includes
);

const needsExtraPolyfills = !(
  window.IntersectionObserver &&
  window.requestIdleCallback
);

// Latest version of Firefox and Safari do not have IntersectionObserver.
// Edge does not have requestIdleCallback.
// This avoids shipping them all the polyfills.
if (needsBasePolyfills) {
  Promise.all([
    import(/* webpackChunkName: "base_polyfills" */ '../mastodon/base_polyfills'),
    import(/* webpackChunkName: "extra_polyfills" */ '../mastodon/extra_polyfills'),
  ]).then(main).catch(e => {
    console.error(e); // eslint-disable-line no-console
  });
} else if (needsExtraPolyfills) {
  import(/* webpackChunkName: "extra_polyfills" */ '../mastodon/extra_polyfills').then(main).catch(e => {
    console.error(e); // eslint-disable-line no-console
  });
} else {
  main();
}
