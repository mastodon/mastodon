import './public-path';
import loadPolyfills from '../mastodon/load_polyfills';
import { start } from '../mastodon/common';

start();

loadPolyfills().then(async () => {
  const { default: main } = await import('mastodon/main');

  return main();
}).catch(e => {
  console.error(e);
});
