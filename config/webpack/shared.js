// Note: You must restart bin/webpack-dev-server for changes to take effect

const { resolve } = require('path');

const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const webpack = require('webpack');
const AssetsManifestPlugin = require('webpack-assets-manifest');

const { env, settings, core, flavours, output } = require('./configuration');
const rules = require('./rules');

function reducePacks (data, into = {}) {
  if (!data.pack) return into;

  for (const entry in data.pack) {
    const pack = data.pack[entry];
    if (!pack) continue;

    let packFiles = [];
    if (typeof pack === 'string')
      packFiles = [pack];
    else if (Array.isArray(pack))
      packFiles = pack;
    else
      packFiles = [pack.filename];

    if (packFiles) {
      into[data.name ? `flavours/${data.name}/${entry}` : `core/${entry}`] = packFiles.map(packFile => resolve(data.pack_directory, packFile));
    }
  }

  if (!data.name) return into;

  for (const skinName in data.skin) {
    const skin = data.skin[skinName];
    if (!skin) continue;

    for (const entry in skin) {
      const packFile = skin[entry];
      if (!packFile) continue;

      into[`skins/${data.name}/${skinName}/${entry}`] = resolve(packFile);
    }
  }

  return into;
}

const entries = Object.assign(
  reducePacks(core),
  Object.values(flavours).reduce((map, data) => reducePacks(data, map), {}),
);


module.exports = {
  entry: entries,

  output: {
    filename: 'js/[name]-[chunkhash].js',
    chunkFilename: 'js/[name]-[chunkhash].chunk.js',
    hotUpdateChunkFilename: 'js/[id]-[hash].hot-update.js',
    hashFunction: 'sha256',
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
          chunks (chunk) {
            return !(chunk.name in entries);
          },
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
