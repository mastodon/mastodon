const objectify = (path, obj) =>
  path.split('.').reduce((prev, curr) => (prev ? prev[curr] : undefined), obj)

module.exports = objectify
