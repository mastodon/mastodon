const { canMerge, prettyPrint } = require('./helpers')
const deepMerge = require('./deep_merge')

const deepAssign = (obj, path, value) => {
  if (!value) throw new Error(`Value can't be ${value}`)

  const keys = path.split('.')
  const key = keys.pop()

  const objRef = keys.reduce((acc, currentValue) => {
    /* eslint no-param-reassign: 0 */
    if (!acc[currentValue]) acc[currentValue] = {}
    return acc[currentValue]
  }, obj)

  if (!objRef) throw new Error(`Prop not found: ${path} in ${prettyPrint(obj)}`)

  objRef[key] = canMerge(value) ? deepMerge(objRef[key], value) : value
  return obj
}

module.exports = deepAssign
