import main from '../mastodon/main';

if (!window.Intl || !Object.assign || !Number.isNaN ||
    !window.Symbol || !Array.prototype.includes) {
  // load polyfills dynamically
  import('../mastodon/polyfills').then(main).catch(e => {
    console.error(e); // eslint-disable-line no-console
  });
} else {
  main();
}
