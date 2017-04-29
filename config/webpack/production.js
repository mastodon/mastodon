// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

const webpack = require('webpack')
const merge = require('webpack-merge')
const CompressionPlugin = require('compression-webpack-plugin')
const BabiliPlugin = require('babili-webpack-plugin')
const sharedConfig = require('./shared.js')

module.exports = merge(sharedConfig, {
  output: { filename: '[name]-[chunkhash].js' },

  plugins: [
    new BabiliPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: true
      },

      output: {
        comments: false
      },

      sourceMap: false
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|svg|eot|ttf|woff|woff2)$/
    })
  ]
})
