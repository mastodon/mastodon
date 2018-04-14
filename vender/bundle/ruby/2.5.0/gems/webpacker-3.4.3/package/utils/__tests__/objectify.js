/* global test expect */

const objectify = require('../objectify')

test('Get object from a string path', () => {
  const object = { foo: { bar: { x: 1 } } }
  expect(objectify('foo.bar', object)).toEqual({ x: 1 })
  expect(objectify('some.bar', object)).toEqual(undefined)
})
