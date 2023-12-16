module.exports = ({ env }) => ({
  plugins: {
    autoprefixer: {},
    cssnano: env === 'production' ? {} : false,
  },
});
