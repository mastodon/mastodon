// Note: You must restart bin/webpack-dev-server for changes to take effect

const webpack = require('webpack');
const { basename, join, resolve } = require('path');
const { sync } = require('glob');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const ManifestPlugin = require('webpack-manifest-plugin');
const extname = require('path-complete-extname');
const { env, settings, core, flavours, output, loadersDir } = require('./configuration.js');
const localePackPaths = require('./generateLocalePacks');

function reducePacks (data, into = {}) {
  if (!data.pack) {
    return into;
  }
  Object.keys(data.pack).reduce((map, entry) => {
    const pack = data.pack[entry];
    if (!pack) {
      return map;
    }
    const packFile = typeof pack === 'string' ? pack : pack.filename;
    if (packFile) {
      map[data.name ? `flavours/${data.name}/${entry}` : `core/${entry}`] = resolve(data.pack_directory, packFile);
    }
    return map;
  }, into);
  if (data.name) {
    Object.keys(data.skin).reduce((map, entry) => {
      const skin = data.skin[entry];
      const skinName = entry;
      if (!skin) {
        return map;
      }
      Object.keys(skin).reduce((map, entry) => {
        const packFile = skin[entry];
        if (!packFile) {
          return map;
        }
        map[`skins/${data.name}/${skinName}/${entry}`] = resolve(packFile);
        return map;
      }, into);
      return map;
    }, into);
  }
  return into;
}

module.exports = {
  entry: Object.assign(
    { locales: resolve('app', 'javascript', 'locales') },
    localePackPaths.reduce((map, entry) => {
      const localMap = map;
      localMap[basename(entry, extname(entry, extname(entry)))] = resolve(entry);
      return localMap;
    }, {}),
    reducePacks(core),
    Object.keys(flavours).reduce((map, entry) => reducePacks(flavours[entry], map), {})
  ),

  output: {
    filename: '[name].js',
    chunkFilename: '[name].js',
    path: output.path,
    publicPath: output.publicPath,
  },

  module: {
    rules: sync(join(loadersDir, '*.js')).map(loader => require(loader)),
  },

  plugins: [
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new webpack.NormalModuleReplacementPlugin(
      /^history\//, (resource) => {
        // temporary fix for https://github.com/ReactTraining/react-router/issues/5576
        // to reduce bundle size
        resource.request = resource.request.replace(/^history/, 'history/es');
      }
    ),
    new ExtractTextPlugin({
      filename: env.NODE_ENV === 'production' ? '[name]-[contenthash].css' : '[name].css',
      allChunks: true,
    }),
    new ManifestPlugin({
      publicPath: output.publicPath,
      writeToFileEmit: true,
    }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'locales',
      minChunks: Infinity, // It doesn't make sense to use common chunks with multiple frontend support.
    }),
  ],

  resolve: {
    extensions: settings.extensions,
    modules: [
      resolve(settings.source_path),
      'node_modules',
    ],
  },

  resolveLoader: {
    modules: ['node_modules'],
  },

  node: {
    // Called by http-link-header in an API we never use, increases
    // bundle size unnecessarily
    Buffer: false,
  },
};
