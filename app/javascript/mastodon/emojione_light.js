// @preval

//     &&&
//    &&&/&
//  &\/&|&&&&
// &&&\&|&/&&&    ,^%---
//  &&&\|/&&&    <   \
//   & }}{  &   />\_&       Do I need
//     }{{     / >       the whole tree?
//              /|^^
// http://ascii.co.uk/art/tree

// Force tree shaking on emojione by exposing just a subset of its functionality

const emojione = require('emojione');

const mappedUnicode = emojione.mapUnicodeToShort();

module.exports.unicodeToFilename = Object.entries(emojione.jsEscapeMap)
  .map(([unicodeStr, unicode]) => [unicodeStr, mappedUnicode[unicode]])
  .map(([unicodeStr, shortCode]) => ({ [unicodeStr]: emojione.emojioneList[shortCode].fname }))
  .reduce((x, y) => Object.assign(x, y), { });
