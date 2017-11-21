import loadPolyfills from '../mastodon/load_polyfills';

loadPolyfills().then(() => {
  require('../mastodon/main').default();
}).catch(e => {
  console.error(e);
});
