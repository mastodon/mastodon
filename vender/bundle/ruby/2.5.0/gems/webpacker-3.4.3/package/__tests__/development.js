/* test expect, describe, afterAll, beforeEach */

const { resolve } = require('path')
const { chdirTestApp, chdirCwd } = require('../utils/helpers')

chdirTestApp()

describe('Development environment', () => {
  afterAll(chdirCwd)

  describe('toWebpackConfig', () => {
    beforeEach(() => jest.resetModules())

    test('should use development config and environment', () => {
      process.env.RAILS_ENV = 'development'
      process.env.NODE_ENV = 'development'
      const { environment } = require('../index')

      const config = environment.toWebpackConfig()
      expect(config.output.path).toEqual(resolve('public', 'packs'))
      expect(config.output.publicPath).toEqual('/packs/')
      expect(config).toMatchObject({
        devServer: {
          host: 'localhost',
          port: 3035
        }
      })
    })
  })
})
