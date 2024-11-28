// A mapping of unicode strings to an object containing the filename
// (i.e. the svg filename) and a shortCode intended to be shown
// as a "title" attribute in an HTML element (aka tooltip).

import type {
  FilenameData,
  ShortCodesToEmojiDataKey,
} from './emoji_compressed';
import emojiCompressed from './emoji_compressed';
import { unicodeToFilename } from './unicode_to_filename';

type UnicodeMapping = {
  [key in FilenameData[number][0]]: {
    shortCode: ShortCodesToEmojiDataKey;
    filename: FilenameData[number][number];
  };
};

const [
  shortCodesToEmojiData,
  _skins,
  _categories,
  _short_names,
  emojisWithoutShortCodes,
] = emojiCompressed;

// decompress
const unicodeMapping: UnicodeMapping = {};

function processEmojiMapData(
  emojiMapData: FilenameData[number],
  shortCode?: ShortCodesToEmojiDataKey,
) {
  const [native, _filename] = emojiMapData;
  let filename = emojiMapData[1];
  if (!filename) {
    // filename name can be derived from unicodeToFilename
    filename = unicodeToFilename(native);
  }
  unicodeMapping[native] = {
    shortCode,
    filename,
  };
}

Object.keys(shortCodesToEmojiData).forEach(
  (shortCode: ShortCodesToEmojiDataKey) => {
    if (shortCode === undefined) return;

    const emojiData = shortCodesToEmojiData[shortCode];
    if (!emojiData) return;
    const [filenameData, _searchData] = emojiData;
    filenameData.forEach((emojiMapData) => {
      processEmojiMapData(emojiMapData, shortCode);
    });
  },
);

emojisWithoutShortCodes.forEach((emojiMapData) => {
  processEmojiMapData(emojiMapData);
});

export { unicodeMapping };
