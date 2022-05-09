const { merge } = require('shakapacker');
const baseConfig = require('./base');

/** @type {import('webpack').Configuration} */
const testConfig = {
  mode: 'development',
};

module.exports = merge({}, baseConfig, testConfig);
