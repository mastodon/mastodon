const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { env } = require('../configuration.js');

module.exports = {
  test: /\.s?css$/i,
  use: [
    MiniCssExtractPlugin.loader,
    {
      loader: 'css-loader',
      options: {
        minimize: env.NODE_ENV === 'production',
      },
    },
    {
      loader: 'postcss-loader',
      options: {
        sourceMap: true,
      },
    },
    'sass-loader',
  ],
};
