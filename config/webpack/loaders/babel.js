module.exports = {
  test: /\.js$/,
  // include react-intl because transform-react-remove-prop-types needs to apply to it
  exclude: /node_modules\/(?!react-intl)/,
  loader: 'babel-loader',
  options: {
    forceEnv: process.env.NODE_ENV || 'development',
  },
};
