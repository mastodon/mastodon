// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

const webpack = require('webpack');
const merge = require('webpack-merge');
const CompressionPlugin = require('compression-webpack-plugin');
const sharedConfig = require('./shared.js');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = merge(sharedConfig, {

  devtool: 'source-map', // separate sourcemap file, suitable for production

  output: { filename: '[name]-[chunkhash].js' },

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compress: true,
      mangle: true,

      output: {
        comments: false,
      },

      sourceMap: true,
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|svg|eot|ttf|woff|woff2)$/,
    }),
    new BundleAnalyzerPlugin({ // generates report.html and stats.json
      analyzerMode: 'static',
      generateStatsFile: true,
      openAnalyzer: false,
    }),
  ],
});
