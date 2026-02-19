import { loadLocale } from 'mastodon/locales';
import main from 'mastodon/main';
import { loadPolyfills } from 'mastodon/polyfills';

loadPolyfills()
  .then(loadLocale)
  .then(main)
  .catch((e: unknown) => {
    console.error(e);
  });
