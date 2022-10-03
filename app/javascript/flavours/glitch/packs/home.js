import 'packs/public-path';
import loadPolyfills from 'flavours/glitch/util/load_polyfills';

loadPolyfills().then(async () => {
  const { default: main } = import('flavours/glitch/util/main');

  return main();
}).catch(e => {
  console.error(e);
});
