/** @type {import('postcss-load-config').Config} */
const config = ({ env }) => ({
  plugins: [
    require('postcss-preset-env'),
    require('autoprefixer'),
    env === 'production' ? require('cssnano') : '',
  ],
});

module.exports = config;
