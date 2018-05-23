const isObject = value =>
  typeof value === 'object' &&
  value !== null &&
  (value.length === undefined || value.length === null)

const isBoolean = str => /^true/.test(str) || /^false/.test(str)

const isEmpty = value => value === null || value === undefined

const isString = key => key && typeof key === 'string'

const isStrPath = (key) => {
  if (!isString(key)) throw new Error(`Key ${key} should be string`)
  return isString(key) && key.includes('.')
}

const isArray = value => Array.isArray(value)

const isEqual = (target, source) => JSON.stringify(target) === JSON.stringify(source)

const canMerge = value => isObject(value) || isArray(value)

const prettyPrint = obj => JSON.stringify(obj, null, 2)

const chdirTestApp = () => {
  try {
    return process.chdir('test/test_app')
  } catch (e) {
    return null
  }
}

const chdirCwd = () => process.chdir(process.cwd())

module.exports = {
  chdirTestApp,
  chdirCwd,
  isObject,
  isBoolean,
  isArray,
  isEqual,
  isEmpty,
  isStrPath,
  canMerge,
  prettyPrint
}
