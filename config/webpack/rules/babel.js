const { join, resolve } = require('path');
const { env, settings } = require('../configuration');

module.exports = {
  test: /\.(js|jsx|mjs)$/,
  include: [
    settings.source_path,
    ...settings.resolved_paths,
  ].map(p => resolve(p)),
  exclude: /node_modules/,
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
