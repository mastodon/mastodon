import loadPolyfills from './util/load_polyfills';

loadPolyfills().then(() => {
  require('./util/main').default();
}).catch(e => {
  console.error(e);
});
