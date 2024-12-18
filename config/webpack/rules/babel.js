const { join, resolve } = require('path');

const { env, settings } = require('../configuration');

// Those modules contain modern ES code that need to be transpiled for Webpack to process it
const nodeModulesToProcess = [
  '@reduxjs', 'fuzzysort'
];

module.exports = {
  test: /\.(js|jsx|mjs|ts|tsx)$/,
  include: [
    settings.source_path,
    ...settings.resolved_paths,
    ...nodeModulesToProcess.map(p => resolve(`node_modules/${p}`)),
  ].map(p => resolve(p)),
  exclude: new RegExp('node_modules\\/(?!(' + nodeModulesToProcess.join('|')+')\\/).*'),
  use: [
    {
      loader: 'babel-loader',
      options: {
        cacheDirectory: join(settings.cache_path, 'babel-loader'),
        cacheCompression: env.NODE_ENV === 'production',
        compact: env.NODE_ENV === 'production',
      },
    },
  ],
};
