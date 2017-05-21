module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'babel-loader',
  options: {
    forceEnv: process.env.NODE_ENV || 'development',
  },
};
