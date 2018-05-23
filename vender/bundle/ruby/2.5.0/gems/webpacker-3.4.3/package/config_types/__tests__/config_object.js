/* global test expect */

const ConfigObject = require('../config_object')

test('new', () => {
  const object = new ConfigObject()
  expect(object).toBeInstanceOf(ConfigObject)
  expect(object).toBeInstanceOf(Object)
})

test('set', () => {
  const object = new ConfigObject()
  expect(object.set('key', 'value')).toEqual({ key: 'value' })
})

test('get', () => {
  const object = new ConfigObject()
  object.set('key', 'value')
  object.set('key1', 'value1')
  expect(object.get('key')).toEqual('value')
})

test('delete', () => {
  const object = new ConfigObject()
  object.set('key', { key1: 'value' })
  expect(object.delete('key.key1')).toEqual({ key: {} })
  expect(object.delete('key')).toEqual({})
})

test('toObject', () => {
  const object = new ConfigObject()
  object.set('key', 'value')
  object.set('key1', 'value1')
  expect(object.toObject()).toEqual({ key: 'value', key1: 'value1' })
})

test('merge', () => {
  const object = new ConfigObject()
  object.set('foo', {})
  expect(object.merge({ key: 'foo', value: 'bar' })).toEqual(
    { foo: {}, key: 'foo', value: 'bar' }
  )
})
