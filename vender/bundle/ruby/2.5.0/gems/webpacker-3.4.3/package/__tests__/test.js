/* test expect, describe, afterAll, beforeEach */

const { resolve } = require('path')
const { chdirTestApp, chdirCwd } = require('../utils/helpers')

chdirTestApp()

describe('Test environment', () => {
  afterAll(chdirCwd)

  describe('toWebpackConfig', () => {
    beforeEach(() => jest.resetModules())

    test('should use test config and production environment', () => {
      process.env.RAILS_ENV = 'test'
      const { environment } = require('../index')

      const config = environment.toWebpackConfig()
      expect(config.output.path).toEqual(resolve('public', 'packs-test'))
      expect(config.output.publicPath).toEqual('/packs-test/')
    })
  })
})
