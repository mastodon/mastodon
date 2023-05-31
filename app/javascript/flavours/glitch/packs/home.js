import 'packs/public-path';
import { loadLocale } from 'flavours/glitch/load_locale';
import { loadPolyfills } from 'flavours/glitch/polyfills';

loadPolyfills().then(loadLocale).then(async () => {
  const { default: main } = await import('flavours/glitch/main');

  return main();
}).catch(e => {
  console.error(e);
});
