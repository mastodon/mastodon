const { resolve } = require('path');

module.exports = {
  test: /\.js$/,
  // include react-intl because transform-react-remove-prop-types needs to apply to it
  exclude: {
    test: /node_modules/,
    exclude: /react-intl[\/\\](?!locale-data)/,
  },
  loader: 'babel-loader',
  options: {
    forceEnv: process.env.NODE_ENV || 'development',
    cacheDirectory: resolve(__dirname, '..', '..', '..', 'tmp', 'cache', 'babel-loader'),
  },
};
