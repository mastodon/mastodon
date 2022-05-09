const { createHash } = require('crypto');
const { readFileSync } = require('fs');
const { resolve } = require('path');
const { merge } = require('shakapacker');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
const { InjectManifest } = require('workbox-webpack-plugin');
const baseConfig = require('./base');

const root = resolve(__dirname, '..', '..', '..');

/** @type {import('webpack').Configuration} */
const productionConfig = {
  plugins: [
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
};

module.exports = merge({}, baseConfig, productionConfig);
