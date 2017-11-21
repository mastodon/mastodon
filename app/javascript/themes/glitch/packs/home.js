import loadPolyfills from 'themes/glitch/util/load_polyfills';

loadPolyfills().then(() => {
  require('themes/glitch/util/main').default();
}).catch(e => {
  console.error(e);
});
