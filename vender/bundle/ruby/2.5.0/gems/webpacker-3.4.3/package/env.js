const { resolve } = require('path')
const { safeLoad } = require('js-yaml')
const { readFileSync } = require('fs')

const NODE_ENVIRONMENTS = ['development', 'production']
const DEFAULT = 'production'
const configPath = resolve('config', 'webpacker.yml')

const railsEnv = process.env.RAILS_ENV
const nodeEnv = process.env.NODE_ENV

const config = safeLoad(readFileSync(configPath), 'utf8')
const availableEnvironments = Object.keys(config).join('|')
const regex = new RegExp(availableEnvironments, 'g')

module.exports = {
  railsEnv: railsEnv && railsEnv.match(regex) ? railsEnv : DEFAULT,
  nodeEnv: nodeEnv && NODE_ENVIRONMENTS.includes(nodeEnv) ? nodeEnv : DEFAULT
}
