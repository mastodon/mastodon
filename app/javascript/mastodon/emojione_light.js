// @preval
// Force tree shaking on emojione by exposing just a subset of its functionality

const emojione = require('emojione');

const mappedUnicode = emojione.mapUnicodeToShort();

module.exports.unicodeToFilename = Object.keys(emojione.jsEscapeMap)
  .map(unicodeStr => [unicodeStr, mappedUnicode[emojione.jsEscapeMap[unicodeStr]]])
  .map(([unicodeStr, shortCode]) => ({ [unicodeStr]: emojione.emojioneList[shortCode].fname }))
  .reduce((x, y) => Object.assign(x, y), { });
