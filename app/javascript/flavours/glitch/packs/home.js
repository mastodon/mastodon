import 'packs/public-path';
import loadPolyfills from 'flavours/glitch/util/load_polyfills';

loadPolyfills().then(() => {
  require('flavours/glitch/util/main').default();
}).catch(e => {
  console.error(e);
});
