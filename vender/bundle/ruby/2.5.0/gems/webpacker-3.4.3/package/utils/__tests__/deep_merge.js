/* global test expect */

const deepMerge = require('../deep_merge')

test('deep merge objects together', () => {
  const object1 = { foo: { bar: [1, 2, 3], z: 1 }, x: 0 }
  const object2 = { foo: { bar: ['x', 'y'] }, x: 1, y: 2 }
  const expectation = { foo: { bar: [1, 2, 3, 'x', 'y'], z: 1 }, x: 1, y: 2 }
  expect(deepMerge(object1, object2)).toEqual(expectation)
})
