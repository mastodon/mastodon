/**
  * @class
  * @extends { Array }
*/
class ConfigList extends Array {
  static get [Symbol.species]() { return Array }

  get(key) {
    const index = this.getIndex(key, true)
    return this[index].value
  }

  append(key, value) {
    return this.add({ key, value })
  }

  prepend(key, value) {
    return this.add({ key, value }, 'prepend')
  }

  insert(key, value, pos = {}) {
    if (!(pos.before || pos.after)) return this.append(key, value)

    const currentIndex = this.getIndex(key)
    if (currentIndex >= 0) this.splice(currentIndex, 1)

    let newIndex = this.getIndex(pos.before || pos.after)
    if (pos.after) newIndex += 1

    this.splice(newIndex, 0, { key, value })
    return this
  }

  delete(key) {
    const index = this.getIndex(key, true)
    this.splice(index, 1)
    return this
  }

  getIndex(key, shouldThrow = false) {
    const index = this.findIndex(entry =>
      (
        entry === key ||
        entry.key === key ||
        (entry.constructor && entry.constructor.name === key)
      ))

    if (shouldThrow && index < 0) throw new Error(`Item ${key} not found`)
    return index
  }

  add({ key, value }, strategy = 'append') {
    const index = this.getIndex(key)
    if (index >= 0) this.delete(key)

    switch (strategy) {
      case 'prepend':
        this.unshift({ key, value })
        break
      default:
        this.push({ key, value })
    }

    return this
  }

  values() {
    return this.map(item => item.value)
  }

  keys() {
    return this.map(item => item.key)
  }
}

module.exports = ConfigList
