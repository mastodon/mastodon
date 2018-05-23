const objectify = require('../utils/objectify')
const deepAssign = require('../utils/deep_assign')
const deepMerge = require('../utils/deep_merge')
const { isStrPath, prettyPrint } = require('../utils/helpers')

/**
  * @class
  * @extends { Object }
*/
class ConfigObject extends Object {
  constructor(props = {}) {
    super()
    this.merge(props)
  }

  get(key) {
    return isStrPath(key) ? objectify(key, this) : this[key]
  }

  set(key, value) {
    Object.assign(this, deepAssign(this, key, value))
    return this
  }

  delete(key) {
    let obj = this
    let propKey = key

    if (isStrPath(key)) {
      const keys = key.split('.')
      propKey = keys.pop()
      const parentObjPath = keys.join('.')
      obj = objectify(parentObjPath, this)
    }

    if (!obj) throw new Error(`Prop not found: ${key} in ${prettyPrint(obj)}`)
    delete obj[propKey]

    return this
  }

  toObject() {
    const object = {}
    /* eslint no-return-assign: 0 */
    Object.keys(this).forEach(key => (object[key] = this[key]))
    return object
  }

  merge(config) {
    Object.assign(this, deepMerge(this, config))
    return this
  }
}

module.exports = ConfigObject
