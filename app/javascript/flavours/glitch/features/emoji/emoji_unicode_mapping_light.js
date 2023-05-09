// A mapping of unicode strings to an object containing the filename
// (i.e. the svg filename) and a shortCode intended to be shown
// as a "title" attribute in an HTML element (aka tooltip).

import emojiCompressed from './emoji_compressed';

import { unicodeToFilename } from './unicode_to_filename';

const [
  shortCodesToEmojiData,
  _skins,
  _categories,
  _short_names,
  emojisWithoutShortCodes,
] = emojiCompressed;

// decompress
const unicodeMapping = {};

function processEmojiMapData(emojiMapData, shortCode) {
  let [ native, filename ] = emojiMapData;
  if (!filename) {
    // filename name can be derived from unicodeToFilename
    filename = unicodeToFilename(native);
  }
  unicodeMapping[native] = {
    shortCode: shortCode,
    filename: filename,
  };
}

Object.keys(shortCodesToEmojiData).forEach((shortCode) => {
  let [ filenameData ] = shortCodesToEmojiData[shortCode];
  filenameData.forEach(emojiMapData => processEmojiMapData(emojiMapData, shortCode));
});
emojisWithoutShortCodes.forEach(emojiMapData => processEmojiMapData(emojiMapData));

export default unicodeMapping;
