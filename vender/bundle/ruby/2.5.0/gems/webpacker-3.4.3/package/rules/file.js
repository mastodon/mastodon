const { join } = require('path')
const { source_path: sourcePath } = require('../config')

module.exports = {
  test: /\.(jpg|jpeg|png|gif|tiff|ico|svg|eot|otf|ttf|woff|woff2)$/i,
  use: [
    {
      loader: 'file-loader',
      options: {
        name: '[path][name]-[hash].[ext]',
        context: join(sourcePath)
      }
    }
  ]
}
