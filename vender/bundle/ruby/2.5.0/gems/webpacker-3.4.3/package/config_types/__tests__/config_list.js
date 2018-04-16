/* global test expect */

const ConfigList = require('../config_list')

test('new', () => {
  const list = new ConfigList()
  expect(list).toBeInstanceOf(ConfigList)
  expect(list).toBeInstanceOf(Array)
})

test('get', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  expect(list.get('key')).toEqual('value')
})

test('append', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  expect(list.append('key1', 'value1')).toEqual([
    { key: 'key', value: 'value' },
    { key: 'key1', value: 'value1' }
  ])
})

test('prepend', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  expect(list.prepend('key1', 'value1')).toEqual([
    { key: 'key1', value: 'value1' },
    { key: 'key', value: 'value' }
  ])
})

test('insert without position', () => {
  const list = new ConfigList()
  list.append('key', 'value')

  expect(list.insert('key1', 'value1')).toEqual([
    { key: 'key', value: 'value' },
    { key: 'key1', value: 'value1' }
  ])

  expect(list.insert('key2', 'value2')).toEqual([
    { key: 'key', value: 'value' },
    { key: 'key1', value: 'value1' },
    { key: 'key2', value: 'value2' }
  ])
})

test('insert before an item', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  list.append('key1', 'value1')

  expect(list.insert('key2', 'value2', { before: 'key' })).toEqual([
    { key: 'key2', value: 'value2' },
    { key: 'key', value: 'value' },
    { key: 'key1', value: 'value1' }
  ])

  expect(list.insert('key3', 'value3', { before: 'key2' })).toEqual([
    { key: 'key3', value: 'value3' },
    { key: 'key2', value: 'value2' },
    { key: 'key', value: 'value' },
    { key: 'key1', value: 'value1' }
  ])
})

test('insert after an item', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  list.append('key1', 'value1')

  expect(list.insert('key2', 'value2', { after: 'key' })).toEqual([
    { key: 'key', value: 'value' },
    { key: 'key2', value: 'value2' },
    { key: 'key1', value: 'value1' }
  ])

  expect(list.insert('key3', 'value3', { after: 'key2' })).toEqual([
    { key: 'key', value: 'value' },
    { key: 'key2', value: 'value2' },
    { key: 'key3', value: 'value3' },
    { key: 'key1', value: 'value1' }
  ])
})

test('delete', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  list.append('key1', 'value1')
  expect(list.delete('key')).toEqual([{ key: 'key1', value: 'value1' }])
  expect(list.delete('key1')).toEqual([])
})

test('getIndex', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  list.append('key1', 'value1')
  expect(list.getIndex('key')).toEqual(0)
  expect(list.getIndex('key2')).toEqual(-1)
  expect(() => list.getIndex('key2', true)).toThrow('Item key2 not found')
})

test('values', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  list.append('key1', 'value1')
  expect(list.values()).toEqual(['value', 'value1'])
})

test('keys', () => {
  const list = new ConfigList()
  list.append('key', 'value')
  list.append('key1', 'value1')
  expect(list.keys()).toEqual(['key', 'key1'])
})
