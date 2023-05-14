import { start } from '../mastodon/common';
import { loadLocale } from '../mastodon/load_locale';
import { loadPolyfills } from '../mastodon/polyfills';

import 'styles/application.scss';

start();

loadPolyfills().then(loadLocale).then(async () => {
  const { main } = await import('mastodon/main');

  return main();
}).catch(e => {
  console.error(e);
});
