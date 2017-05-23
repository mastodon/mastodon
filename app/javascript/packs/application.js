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

if (needsBasePolyfills) {
  Promise.all([
    import('../mastodon/base_polyfills'),
    import('../mastodon/extra_polyfills'),
  ]).then(main).catch(e => {
    console.error(e); // eslint-disable-line no-console
  });
} else if (needsExtraPolyfills) {
  import('../mastodon/extra_polyfills').then(main).catch(e => {
    console.error(e); // eslint-disable-line no-console
  });
} else {
  main();
}
