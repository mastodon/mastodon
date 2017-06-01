import main from '../mastodon/main';
import loadPolyfills from '../mastodon/load_polyfills';

loadPolyfills().then(main).catch(e => {
  console.error(e); // eslint-disable-line no-console
});
