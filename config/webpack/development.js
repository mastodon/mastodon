// Note: You must restart bin/webpack-dev-server for changes to take effect

const { merge } = require('webpack-merge');
const sharedConfig = require('./shared');
const { settings, output } = require('./configuration');

const watchOptions = {};

if (process.env.VAGRANT) {
  // If we are in Vagrant, we can't rely on inotify to update us with changed
  // files, so we must poll instead. Here, we poll every second to see if
  // anything has changed.
  watchOptions.poll = 1000;
}

module.exports = merge(sharedConfig, {
  mode: 'development',
  cache: true,
  devtool: 'cheap-module-eval-source-map',

  stats: {
    errorDetails: true,
  },

  output: {
    pathinfo: true,
  },

  devServer: {
    clientLogLevel: 'none',
    compress: settings.dev_server.compress,
    quiet: settings.dev_server.quiet,
    disableHostCheck: settings.dev_server.disable_host_check,
    host: settings.dev_server.host,
    port: settings.dev_server.port,
    https: settings.dev_server.https,
    hot: settings.dev_server.hmr,
    contentBase: output.path,
    inline: settings.dev_server.inline,
    useLocalIp: settings.dev_server.use_local_ip,
    public: settings.dev_server.public,
    publicPath: output.publicPath,
    historyApiFallback: {
      disableDotRule: true,
    },
    headers: settings.dev_server.headers,
    overlay: settings.dev_server.overlay,
    stats: {
      entrypoints: false,
      errorDetails: false,
      modules: false,
      moduleTrace: false,
    },
    watchOptions: Object.assign(
      {},
      settings.dev_server.watch_options,
      watchOptions,
    ),
    writeToDisk: filePath => /ocr/.test(filePath),
  },
});
