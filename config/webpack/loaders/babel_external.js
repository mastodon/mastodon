const { resolve } = require('path');

const env = process.env.NODE_ENV || 'development';

if (env === 'development') {
  module.exports = {};
} else {
  // babel options to apply only to external libraries, e.g. remove-prop-types
  module.exports = {
    test: /\.js$/,
    include: /node_modules/,
    loader: 'babel-loader',
    options: {
      babelrc: false,
      plugins: [
        'transform-react-remove-prop-types',
      ],
      cacheDirectory: env === 'development' ? false : resolve(__dirname, '..', '..', '..', 'tmp', 'cache', 'babel-loader-external'),
    },
  };
}
