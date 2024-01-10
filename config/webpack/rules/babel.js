const { join, resolve } = require('path');

const { env, settings } = require('../configuration');

module.exports = {
  test: /\.(js|jsx|mjs|ts|tsx)$/,
  include: [
    settings.source_path,
    ...settings.resolved_paths,
    'node_modules/@reduxjs'
  ].map(p => resolve(p)),
  exclude: function(modulePath) {
    return (
      /node_modules/.test(modulePath) &&
      !/@reduxjs/.test(modulePath)
    );
  },
  use: [
    {
      loader: 'babel-loader',
      options: {
        sourceRoot: 'app/javascript',
        cacheDirectory: join(settings.cache_path, 'babel-loader'),
        cacheCompression: env.NODE_ENV === 'production',
        compact: env.NODE_ENV === 'production',
      },
    },
  ],
};
