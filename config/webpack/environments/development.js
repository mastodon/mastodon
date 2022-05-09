const { env, merge } = require('shakapacker');
const markRule = require('../rules/mark');
const baseConfig = require('./base');

/** @type {import('webpack').Configuration} */
let developmentConfig = {
  module: {
    rules: [
      markRule,
    ],
  },
};

if (env.runningWebpackDevServer) {
  developmentConfig = merge(developmentConfig, {
    devServer: {
      devMiddleware: {
        writeToDisk: filePath => /ocr/.test(filePath),
      },
    },
  });
}

if (process.env.VAGRANT) {
  developmentConfig = merge(developmentConfig, {
    devServer: {
      static: {
        watch: {
          // If we are in Vagrant, we can't rely on inotify to update us with changed
          // files, so we must poll instead. Here, we poll every second to see if
          // anything has changed.
          poll: 1_000,
        },
      },
    },
  });
}

module.exports = merge({}, baseConfig, developmentConfig);
