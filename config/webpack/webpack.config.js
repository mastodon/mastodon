const { existsSync } = require('fs');
const { resolve } = require('path');
const { env } = require('shakapacker');
const baseConfig = require('./environments/base');

function getWebpackConfig() {
  const { nodeEnv } = env;
  const path = resolve(__dirname, 'environments', `${nodeEnv}.js`);
  const enviromentConfig = existsSync(path) ? require(path) : baseConfig;

  return enviromentConfig;
}

module.exports = getWebpackConfig();
