/* global test expect, describe */

const { chdirTestApp, chdirCwd } = require('../utils/helpers')

chdirTestApp()

describe('Env', () => {
  beforeEach(() => jest.resetModules())
  afterAll(chdirCwd)

  test('with NODE_ENV and RAILS_ENV set to development', () => {
    process.env.RAILS_ENV = 'development'
    process.env.NODE_ENV = 'development'
    expect(require('../env')).toEqual({
      railsEnv: 'development',
      nodeEnv: 'development'
    })
  })

  test('with undefined NODE_ENV and RAILS_ENV set to development', () => {
    process.env.RAILS_ENV = 'development'
    delete process.env.NODE_ENV
    expect(require('../env')).toEqual({
      railsEnv: 'development',
      nodeEnv: 'production'
    })
  })

  test('with undefined NODE_ENV and RAILS_ENV', () => {
    delete process.env.NODE_ENV
    delete process.env.RAILS_ENV
    expect(require('../env')).toEqual({
      railsEnv: 'production',
      nodeEnv: 'production'
    })
  })

  test('with a non-standard environment', () => {
    process.env.RAILS_ENV = 'staging'
    process.env.NODE_ENV = 'staging'
    expect(require('../env')).toEqual({
      railsEnv: 'staging',
      nodeEnv: 'production'
    })
  })
})
