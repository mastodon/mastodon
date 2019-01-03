module.exports = ({ env }) => ({
  plugins: {
    autoprefixer: {},
    'postcss-object-fit-images': {},
    cssnano: env === 'production' ? {} : false,
  },
});
