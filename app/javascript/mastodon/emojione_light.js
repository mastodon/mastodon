// @preval
// Force tree shaking on emojione by exposing just a subset of its functionality

const emojione = require('emojione');

const mappedUnicode = emojione.mapUnicodeToShort();

module.exports.unicodeMapping = Object.keys(emojione.jsEscapeMap)
  .map(unicodeStr => [unicodeStr, mappedUnicode[emojione.jsEscapeMap[unicodeStr]]])
  .map(([unicodeStr, shortCode]) => ({ [unicodeStr]: [emojione.emojioneList[shortCode].fname, shortCode.slice(1, shortCode.length - 1)] }))
  .reduce((x, y) => Object.assign(x, y), { });
