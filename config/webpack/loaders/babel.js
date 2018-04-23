const { resolve } = require('path');

const env = process.env.NODE_ENV || 'development';
const cacheDirectory = env === 'development' ? false : resolve(__dirname, '..', '..', '..', 'tmp', 'cache', 'babel-loader');

module.exports = {
  test: /\.js$/,
  exclude: /node_modules/,
  use: [
    'thread-loader',
    {
      loader: 'babel-loader',
      options: {
        forceEnv: env,
        cacheDirectory,
      },
    },
  ],
};
