const babel = require('./babel');
const css = require('./css');
const file = require('./file');
const nodeModules = require('./node_modules');

// Webpack loaders are processed in reverse order
// https://webpack.js.org/concepts/loaders/#loader-features
// Lastly, process static files using file loader
module.exports = {
  file,
  css,
  nodeModules,
  babel,
};
