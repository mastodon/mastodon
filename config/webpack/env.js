const { config, env } = require('shakapacker');

module.exports = {
  NODE_ENV: env.nodeEnv,
  PUBLIC_OUTPUT_PATH: config.public_output_path,
};
