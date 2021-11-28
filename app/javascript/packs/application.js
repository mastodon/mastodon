import './public-path';
import loadPolyfills from '../mastodon/load_polyfills';
import { start } from '../mastodon/common';
import 'regenerator-runtime';

start();

loadPolyfills().then(() => {
  require('../mastodon/main').default();
}).catch(e => {
  console.error(e);
});
