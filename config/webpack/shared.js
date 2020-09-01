// Note: You must restart bin/webpack-dev-server for changes to take effect

const webpack = require('webpack');
const { basename, dirname, join, relative, resolve } = require('path');
const { sync } = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const AssetsManifestPlugin = require('webpack-assets-manifest');
const { env, settings, core, flavours, output } = require('./configuration.js');
const rules = require('./rules');
const localePacks = require('./generateLocalePacks');

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

const entries = Object.assign(
  { locales: resolve('app', 'javascript', 'locales') },
  localePacks,
  reducePacks(core),
  Object.keys(flavours).reduce((map, entry) => reducePacks(flavours[entry], map), {})
);


module.exports = {
  entry: entries,

  output: {
    filename: 'js/[name]-[chunkhash].js',
    chunkFilename: 'js/[name]-[chunkhash].chunk.js',
    hotUpdateChunkFilename: 'js/[id]-[hash].hot-update.js',
    path: output.path,
    publicPath: output.publicPath,
  },

  optimization: {
    runtimeChunk: {
      name: 'locales',
    },
    splitChunks: {
      cacheGroups: {
        default: false,
        vendors: false,
        common: {
          name: 'common',
          chunks (chunk) {
            return !(chunk.name in entries);
          },
          minChunks: 2,
          minSize: 0,
          test: /^(?!.*[\\\/]node_modules[\\\/]react-intl[\\\/]).+$/,
        },
      },
    },
    occurrenceOrder: true,
  },

  module: {
    rules: Object.keys(rules).map(key => rules[key]),
  },

  plugins: [
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new webpack.NormalModuleReplacementPlugin(
      /^history\//, (resource) => {
        // temporary fix for https://github.com/ReactTraining/react-router/issues/5576
        // to reduce bundle size
        resource.request = resource.request.replace(/^history/, 'history/es');
      },
    ),
    new MiniCssExtractPlugin({
      filename: 'css/[name]-[contenthash:8].css',
      chunkFilename: 'css/[name]-[contenthash:8].chunk.css',
    }),
    new AssetsManifestPlugin({
      integrity: false,
      entrypoints: true,
      writeToDisk: true,
      publicPath: true,
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
