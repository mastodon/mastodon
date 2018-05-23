const { resolve } = require('path')

const isProduction = process.env.NODE_ENV === 'production'
const elmSource = resolve(process.cwd())
const elmMake = `${elmSource}/node_modules/.bin/elm-make`

const elmDefaultOptions = { cwd: elmSource, pathToMake: elmMake }
const developmentOptions = Object.assign({}, elmDefaultOptions, {
  verbose: true,
  warn: true,
  debug: true
})

const elmWebpackLoader = {
  loader: 'elm-webpack-loader',
  options: isProduction ? elmDefaultOptions : developmentOptions
}

module.exports = {
  test: /\.elm(\.erb)?$/,
  exclude: [/elm-stuff/, /node_modules/],
  use: isProduction ? [elmWebpackLoader] : [{ loader: 'elm-hot-loader' }, elmWebpackLoader]
}
