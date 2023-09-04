const babel = require('./babel');
const css = require('./css');
const file = require('./file');
const materialIcons = require('./material_icons');
const nodeModules = require('./node_modules');
const tesseract = require('./tesseract');

// Webpack loaders are processed in reverse order
// https://webpack.js.org/concepts/loaders/#loader-features
// Lastly, process static files using file loader
module.exports = {
  materialIcons,
  file,
  tesseract,
  css,
  nodeModules,
  babel,
};
