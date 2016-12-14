const path = require('path');

module.exports = {
  module: {
    loaders: [
      {
        test: /.scss$/,
        loaders: ["style", "css", "sass"],
        include: path.resolve(__dirname, '../')
      }
    ]
  }
}
