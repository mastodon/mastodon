import 'packs/public-path';
import loadPolyfills from 'flavours/glitch/utils/load_polyfills';

loadPolyfills().then(async () => {
  const { default: main } = await import('flavours/glitch/utils/main');

  return main();
}).catch(e => {
  console.error(e);
});
