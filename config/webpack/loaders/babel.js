module.exports = {
  test: /\.js$/,
  // include react-intl because transform-react-remove-prop-types needs to apply to it
  exclude: {
    test: /node_modules/,
    exclude: /react-intl[\/\\](?!locale-data)/,
  },
  loader: 'babel-loader',
  options: {
    forceEnv: process.env.NODE_ENV || 'development',
  },
};
