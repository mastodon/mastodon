module.exports = ({ env }) => ({
  plugins: [
    'postcss-preset-env',
    'autoprefixer',
    env === 'production' ? 'cssnano' : '',
  ],
});
