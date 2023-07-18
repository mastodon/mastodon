const babel = require('./babel');
const css = require('./css');
const file = require('./file');
const nodeModules = require('./node_modules');
const tesseract = require('./tesseract');

// Webpack loaders are processed in reverse order
// https://webpack.js.org/concepts/loaders/#loader-features
// Lastly, process static files using file loader
module.exports = {
  file,
  tesseract,
  css,
  nodeModules,
  babel,
};
