import loadPolyfills from './util/load_polyfills';

// import default stylesheet with variables
require('font-awesome/css/font-awesome.css');

import './styles/index.scss';

require.context('../../images/', true);

loadPolyfills().then(() => {
  require('./util/main').default();
}).catch(e => {
  console.error(e);
});
