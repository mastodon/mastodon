// Note: You must restart bin/webpack-dev-server for changes to take effect

const webpack = require('webpack');
const merge = require('webpack-merge');
const CompressionPlugin = require('compression-webpack-plugin');
const sharedConfig = require('./shared.js');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
const OfflinePlugin = require('offline-plugin');
const { publicPath } = require('./configuration.js');
const path = require('path');
const { URL } = require('whatwg-url');

let compressionAlgorithm;
try {
  const zopfli = require('node-zopfli');
  compressionAlgorithm = (content, options, fn) => {
    zopfli.gzip(content, options, fn);
  };
} catch (error) {
  compressionAlgorithm = 'gzip';
}

let attachmentHost;

if (process.env.S3_ENABLED === 'true') {
  if (process.env.S3_CLOUDFRONT_HOST) {
    attachmentHost = process.env.S3_CLOUDFRONT_HOST;
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
  output: {
    filename: '[name]-[chunkhash].js',
    chunkFilename: '[name]-[chunkhash].js',
  },

  devtool: 'source-map', // separate sourcemap file, suitable for production
  stats: 'normal',

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      sourceMap: true,
      mangle: true,

      compress: {
        warnings: false,
      },

      output: {
        comments: false,
      },
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: compressionAlgorithm,
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/,
    }),
    new BundleAnalyzerPlugin({ // generates report.html and stats.json
      analyzerMode: 'static',
      generateStatsFile: true,
      statsOptions: {
        // allows usage with http://chrisbateman.github.io/webpack-visualizer/
        chunkModules: true,
      },
      openAnalyzer: false,
      logLevel: 'silent', // do not bother Webpacker, who runs with --json and parses stdout
    }),
    new OfflinePlugin({
      publicPath: publicPath, // sw.js must be served from the root to avoid scope issues
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
