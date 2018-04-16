const {
  isObject, isArray, isEqual, isEmpty
} = require('./helpers')

const deepMerge = (target, source) => {
  if (isEmpty(target)) return source
  if (isEmpty(source)) return target
  if (isEqual(target, source)) return source
  if (isArray(target) && isArray(source)) return [...new Set([...target, ...source])]
  if (!(isObject(target) && isObject(source))) return source

  return [...Object.keys(target), ...Object.keys(source)].reduce(
    (result, key) =>
      (Object.assign(
        {},
        result,
        { [key]: deepMerge(target[key], source[key]) }
      )),
    {}
  )
}

module.exports = deepMerge
