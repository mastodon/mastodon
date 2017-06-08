const path = require('path');

module.exports = {
  module: {
    rules: [
      {
        test: /\.(jpg|jpeg|png|gif|svg|eot|ttf|woff|woff2)$/i,
        loader: 'url-loader',
      },
      {
        test: /.scss$/,
        loaders: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader'],
      },
    ],
  },
  resolve: {
    alias: {
      mastodon: path.resolve(__dirname, '..', 'app', 'javascript', 'mastodon'),
    },
  },
};
