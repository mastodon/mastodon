const webpack = require('webpack')
const CompressionPlugin = require('compression-webpack-plugin')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
const Base = require('./base')

module.exports = class extends Base {
  constructor() {
    super()

    this.plugins.append('ModuleConcatenation', new webpack.optimize.ModuleConcatenationPlugin())

    this.plugins.append(
      'UglifyJs',
      new UglifyJsPlugin({
        parallel: true,
        cache: true,
        sourceMap: true,
        uglifyOptions: {
          ie8: false,
          ecma: 8,
          warnings: false,
          mangle: {
            safari10: true
          },
          compress: {
            warnings: false,
            comparisons: false
          },
          output: {
            ascii_only: true
          }
        }
      })
    )

    this.plugins.append(
      'Compression',
      new CompressionPlugin({
        asset: '[path].gz[query]',
        algorithm: 'gzip',
        test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
      })
    )

    this.config.merge({
      devtool: 'nosources-source-map',
      stats: 'normal'
    })
  }
}
