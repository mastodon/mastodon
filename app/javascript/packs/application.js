import loadPolyfills from '../mastodon/load_polyfills';
import { loadHotKeys } from '../mastodon/features/ui/util/optional_hotkeys';

Promise.all([loadPolyfills(), loadHotKeys()]).then(() => {
  require('../mastodon/main').default();
}).catch(e => {
  console.error(e);
});
