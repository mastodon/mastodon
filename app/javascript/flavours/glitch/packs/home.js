import 'packs/public-path';
import loadPolyfills from 'flavours/glitch/load_polyfills';

loadPolyfills().then(async () => {
  const { default: main } = await import('flavours/glitch/main');

  return main();
}).catch(e => {
  console.error(e);
});
