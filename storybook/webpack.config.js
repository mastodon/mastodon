const path = require('path');

module.exports = {
  module: {
    loaders: [
      {
        test: /\.(jpg|jpeg|png|gif|svg|eot|ttf|woff|woff2)$/i,
        loader: 'url-loader'
      },
      {
        test: /.scss$/,
        loaders: ["style-loader", "css-loader", "postcss-loader", "sass-loader"]
      }
    ]
  },
  resolve: {
    modulesDirectories: [
      path.resolve(__dirname, '..', 'storybook'),
      path.resolve(__dirname, '..', 'app', 'javascript'),
      path.resolve(__dirname, '..', 'node_modules')
    ]
  }
};
