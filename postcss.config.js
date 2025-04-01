const postcssPresetEnv = require('postcss-preset-env');

/** @type {import('postcss-load-config').Config} */
const config = () => ({
  plugins: [
    postcssPresetEnv({
      features: {
        'logical-properties-and-values': false
      }
    }),
  ],
});

module.exports = config;
