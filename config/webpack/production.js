// Note: You must restart bin/webpack-dev-server for changes to take effect

const { createHash } = require('crypto');
const { readFileSync } = require('fs');
const { resolve } = require('path');
const { merge } = require('webpack-merge');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
const TerserPlugin = require('terser-webpack-plugin');
const CompressionPlugin = require('compression-webpack-plugin');
const { InjectManifest } = require('workbox-webpack-plugin');
const sharedConfig = require('./shared');

const root = resolve(__dirname, '..', '..');

module.exports = merge(sharedConfig, {
  mode: 'production',
  devtool: 'source-map',
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
    new InjectManifest({
      additionalManifestEntries: ['1f602.svg', 'sheet_13.png'].map((filename) => {
        const path = resolve(root, 'public', 'emoji', filename);
        const body = readFileSync(path);
        const md5  = createHash('md5');

        md5.update(body);

        return {
          revision: md5.digest('hex'),
          url: `/emoji/${filename}`,
        };
      }),
      exclude: [
        /(?:base|extra)_polyfills-.*\.js$/,
        /locale_.*\.js$/,
        /mailer-.*\.(?:css|js)$/,
      ],
      include: [/\.js$/, /\.css$/],
      maximumFileSizeToCacheInBytes: 2 * 1_024 * 1_024, // 2 MiB
      swDest: resolve(root, 'public', 'packs', 'sw.js'),
      swSrc: resolve(root, 'app', 'javascript', 'mastodon', 'service_worker', 'entry.js'),
    }),
  ],
});
