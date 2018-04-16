/* test expect, describe, afterAll, beforeEach */

const { resolve } = require('path')
const { chdirTestApp, chdirCwd } = require('../utils/helpers')

chdirTestApp()

describe('Production environment', () => {
  afterAll(chdirCwd)

  describe('toWebpackConfig', () => {
    beforeEach(() => jest.resetModules())

    test('should use production config and environment', () => {
      process.env.RAILS_ENV = 'production'
      const { environment } = require('../index')

      const config = environment.toWebpackConfig()
      expect(config.output.path).toEqual(resolve('public', 'packs'))
      expect(config.output.publicPath).toEqual('/packs/')
      expect(config).toMatchObject({
        devtool: 'nosources-source-map',
        stats: 'normal'
      })
    })
  })
})
