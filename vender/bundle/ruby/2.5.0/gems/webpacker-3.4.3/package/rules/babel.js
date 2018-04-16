const { join } = require('path')
const { cache_path: cachePath } = require('../config')

module.exports = {
  test: /\.(js|jsx)?(\.erb)?$/,
  exclude: /node_modules/,
  use: [
    {
      loader: 'babel-loader',
      options: {
        cacheDirectory: join(cachePath, 'babel-loader')
      }
    }
  ]
}
