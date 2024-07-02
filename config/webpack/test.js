const { merge } = require('webpack-merge');

const sharedConfig = require('./shared');

module.exports = merge(sharedConfig, {
  mode: 'development',
  cache: false,
});
