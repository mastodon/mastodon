// Note: You must restart bin/webpack-dev-server for changes to take effect

const { resolve } = require('node:path');

const CompressionPlugin = require('compression-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
const { merge } = require('webpack-merge');

const sharedConfig = require('./shared');

const root = resolve(__dirname, '..', '..');

module.exports = merge(sharedConfig, {
  mode: 'production',
  devtool: 'source-map',
  entry: {
    sw: resolve(root, 'app', 'javascript', 'mastodon', 'service_worker', 'entry.js'),
  },
  stats: 'normal',
  bail: true,
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        cache: true,
        parallel: true,
        sourceMap: true,
      }),
    ],
  },

  plugins: [
    new CompressionPlugin({
      filename: '[path][base].gz[query]',
      cache: true,
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/,
    }),
    new CompressionPlugin({
      filename: '[path][base].br[query]',
      algorithm: 'brotliCompress',
      cache: true,
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/,
    }),
    new BundleAnalyzerPlugin({ // generates report.html
      analyzerMode: 'static',
      openAnalyzer: false,
      logLevel: 'silent', // do not bother Webpacker, who runs with --json and parses stdout
    }),
  ],
});
