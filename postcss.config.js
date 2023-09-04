module.exports = ({ env }) => ({
  plugins: [
    'autoprefixer',
    env === 'production' ? 'cssnano' : '',
  ],
});
