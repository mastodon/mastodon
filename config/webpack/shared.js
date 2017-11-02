// Note: You must restart bin/webpack-dev-server for changes to take effect

const webpack = require('webpack');
const { basename, dirname, join, relative, resolve, sep } = require('path');
const { sync } = require('glob');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const ManifestPlugin = require('webpack-manifest-plugin');
const extname = require('path-complete-extname');
const { env, settings, themes, output, loadersDir } = require('./configuration.js');
const localePackPaths = require('./generateLocalePacks');

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
    localePackPaths.reduce((map, entry) => {
      const localMap = map;
      localMap[basename(entry, extname(entry, extname(entry)))] = resolve(entry);
      return localMap;
    }, {}),
    Object.keys(themes).reduce((themePaths, name) => {
      themePaths[name] = resolve(join(settings.source_path, themes[name]));
      return themePaths;
    }, {})
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
    new ExtractTextPlugin(env.NODE_ENV === 'production' ? '[name]-[contenthash].css' : '[name].css'),
    new ManifestPlugin({
      publicPath: output.publicPath,
      writeToFileEmit: true,
    }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'common',
      minChunks: (module, count) => {
        const reactIntlPathRegexp = new RegExp(`node_modules\\${sep}react-intl`);

        if (module.resource && reactIntlPathRegexp.test(module.resource)) {
          // skip react-intl because it's useless to put in the common chunk,
          // e.g. because "shared" modules between zh-TW and zh-CN will never
          // be loaded together
          return false;
        }

        return count >= 2;
      },
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
