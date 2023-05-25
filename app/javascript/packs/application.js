import './public-path';
import { start } from '../mastodon/common';
import { loadPolyfills } from '../mastodon/polyfills';

start();

loadPolyfills().then(async () => {
  const { default: main } = await import('mastodon/main');

  return main();
}).catch(e => {
  console.error(e);
});
