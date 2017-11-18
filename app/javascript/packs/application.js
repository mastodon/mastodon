//  THIS IS THE `vanilla` THEME PACK FILE!!
//  IT'S HERE FOR UPSTREAM COMPATIBILITY!!
//  THE `glitch` PACK FILE IS IN `themes/glitch/index.js`!!

import loadPolyfills from '../mastodon/load_polyfills';

// import default stylesheet with variables
require('font-awesome/css/font-awesome.css');

import '../styles/application.scss';

require.context('../images/', true);

loadPolyfills().then(() => {
  require('../mastodon/main').default();
}).catch(e => {
  console.error(e);
});
