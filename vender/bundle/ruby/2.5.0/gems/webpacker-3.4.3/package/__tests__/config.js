/* global test expect, describe */

const { chdirTestApp, chdirCwd } = require('../utils/helpers')

chdirTestApp()

const config = require('../config')

describe('Config', () => {
  afterAll(chdirCwd)

  test('should return extensions as listed in app config', () => {
    expect(config.extensions).toEqual([
      '.js',
      '.sass',
      '.scss',
      '.css',
      '.module.sass',
      '.module.scss',
      '.module.css',
      '.png',
      '.svg',
      '.gif',
      '.jpeg',
      '.jpg'
    ])
  })
})
