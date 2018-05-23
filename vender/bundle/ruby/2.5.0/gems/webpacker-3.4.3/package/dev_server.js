const { isBoolean } = require('./utils/helpers')
const config = require('./config')

const fetch = (key) => {
  const value = process.env[key]
  return isBoolean(value) ? JSON.parse(value) : value
}

const devServerConfig = config.dev_server

if (devServerConfig) {
  Object.keys(devServerConfig).forEach((key) => {
    const envValue = fetch(`WEBPACKER_DEV_SERVER_${key.toUpperCase().replace(/_/g, '')}`)
    if (envValue) devServerConfig[key] = envValue
  })
}

module.exports = devServerConfig || {}
