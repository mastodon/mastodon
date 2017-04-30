// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

const webpack = require('webpack')
const merge = require('webpack-merge')
const CompressionPlugin = require('compression-webpack-plugin')
const sharedConfig = require('./shared.js')

module.exports = merge(sharedConfig, {
  output: { filename: '[name]-[chunkhash].js' },

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        unused: true,
        evaluate: true,
        booleans: true,
        drop_debugger: true,
        dead_code: true,
        pure_getters: true,
        negate_iife: true,
        conditionals: true,
        loops: true,
        cascade: true,
        keep_fargs: false,
        warnings: true
      },

      mangle: false,

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
