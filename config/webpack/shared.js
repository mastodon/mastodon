// Note: You must restart bin/webpack-dev-server for changes to take effect

const { basename, dirname, join, relative, resolve } = require('path');

const CircularDependencyPlugin = require('circular-dependency-plugin');
const { sync } = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const extname = require('path-complete-extname');
const webpack = require('webpack');
const AssetsManifestPlugin = require('webpack-assets-manifest');

const { env, settings, themes, output } = require('./configuration');
const rules = require('./rules');

const extensionGlob = `**/*{${settings.extensions.join(',')}}*`;
const entryPath = join(settings.source_path, settings.source_entry_path);
const packPaths = sync(join(entryPath, extensionGlob));

module.exports = {
  entry: Object.assign(
    packPaths.reduce((map, entry) => {
      const localMap = map;
      const namespace = relative(join(entryPath), dirname(entry));
      localMap[join(namespace, basename(entry, extname(entry)))] = resolve(entry);
      return localMap;
    }, {}),
    Object.keys(themes).reduce((themePaths, name) => {
      themePaths[name] = resolve(join(settings.source_path, themes[name]));
      return themePaths;
    }, {}),
  ),

  output: {
    filename: 'js/[name]-[chunkhash].js',
    chunkFilename: 'js/[name]-[chunkhash].chunk.js',
    hotUpdateChunkFilename: 'js/[id]-[hash].hot-update.js',
    hashFunction: 'sha256',
    crossOriginLoading: 'anonymous',
    path: output.path,
    publicPath: output.publicPath,
  },

  optimization: {
    runtimeChunk: {
      name: 'common',
    },
    splitChunks: {
      cacheGroups: {
        default: false,
        vendors: false,
        common: {
          name: 'common',
          chunks: 'all',
          minChunks: 2,
          minSize: 0,
          test: /^(?!.*[\\/]node_modules[\\/]react-intl[\\/]).+$/,
        },
      },
    },
    occurrenceOrder: true,
  },

  module: {
    rules: Object.keys(rules).map(key => rules[key]),
    strictExportPresence: true,
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
      integrity: true,
      integrityHashes: ['sha256'],
      entrypoints: true,
      writeToDisk: true,
      publicPath: true,
    }),
    new CircularDependencyPlugin({
      failOnError: true,
    })
  ],

  resolve: {
    extensions: settings.extensions,
    modules: [
      resolve(settings.source_path),
      'node_modules',
    ],
    alias: {
      "@": resolve(settings.source_path),
    }
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
