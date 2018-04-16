/* global test expect */

const deepAssign = require('../deep_assign')

test('deep assign property', () => {
  const object = { foo: { bar: { } } }
  const path = 'foo.bar'
  const value = { x: 1, y: 2 }
  const expectation = { foo: { bar: { x: 1, y: 2 } } }
  expect(deepAssign(object, path, value)).toEqual(expectation)
})
