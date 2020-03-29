// Note: You must restart bin/webpack-dev-server for changes to take effect

const path = require('path');
const { URL } = require('url');
const merge = require('webpack-merge');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
const OfflinePlugin = require('offline-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const CompressionPlugin = require('compression-webpack-plugin');
const { output } = require('./configuration');
const sharedConfig = require('./shared');

let attachmentHost;

if (process.env.S3_ENABLED === 'true') {
  if (process.env.S3_ALIAS_HOST || process.env.S3_CLOUDFRONT_HOST) {
    attachmentHost = process.env.S3_ALIAS_HOST || process.env.S3_CLOUDFRONT_HOST;
  } else {
    attachmentHost = process.env.S3_HOSTNAME || `s3-${process.env.S3_REGION || 'us-east-1'}.amazonaws.com`;
  }
} else if (process.env.SWIFT_ENABLED === 'true') {
  const { host } = new URL(process.env.SWIFT_OBJECT_URL);
  attachmentHost = host;
} else {
  attachmentHost = null;
}

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
      filename: '[path].gz[query]',
      cache: true,
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/,
    }),
    new BundleAnalyzerPlugin({ // generates report.html
      analyzerMode: 'static',
      openAnalyzer: false,
      logLevel: 'silent', // do not bother Webpacker, who runs with --json and parses stdout
    }),
    new OfflinePlugin({
      publicPath: output.publicPath, // sw.js must be served from the root to avoid scope issues
      safeToUseOptionalCaches: true,
      caches: {
        main: [':rest:'],
        additional: [':externals:'],
        optional: [
          '**/locale_*.js', // don't fetch every locale; the user only needs one
          '**/*_polyfills-*.js', // the user may not need polyfills
          '**/*.woff2', // the user may have system-fonts enabled
          // images/audio can be cached on-demand
          '**/*.png',
          '**/*.jpg',
          '**/*.jpeg',
          '**/*.svg',
          '**/*.mp3',
          '**/*.ogg',
        ],
      },
      externals: [
        '/emoji/1f602.svg', // used for emoji picker dropdown
        '/emoji/sheet_10.png', // used in emoji-mart
      ],
      excludes: [
        '**/*.gz',
        '**/*.map',
        'stats.json',
        'report.html',
        // any browser that supports ServiceWorker will support woff2
        '**/*.eot',
        '**/*.ttf',
        '**/*-webfont-*.svg',
        '**/*.woff',
      ],
      ServiceWorker: {
        entry: `imports-loader?ATTACHMENT_HOST=>${encodeURIComponent(JSON.stringify(attachmentHost))}!${encodeURI(path.join(__dirname, '../../app/javascript/mastodon/service_worker/entry.js'))}`,
        cacheName: 'mastodon',
        output: '../assets/sw.js',
        publicPath: '/sw.js',
        minify: true,
      },
    }),
  ],
});
