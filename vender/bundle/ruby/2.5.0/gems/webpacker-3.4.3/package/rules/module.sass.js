const getStyleRule = require('../utils/get_style_rule')

module.exports = getStyleRule(/\.(scss|sass)$/i, true, [
  {
    loader: 'sass-loader',
    options: { sourceMap: true }
  }
])
