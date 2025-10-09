// A mapping of unicode strings to an object containing the filename
// (i.e. the svg filename) and a shortCode intended to be shown
// as a "title" attribute in an HTML element (aka tooltip).

import emojiCompressed from 'virtual:mastodon-emoji-compressed';
import type {
  FilenameData,
  ShortCodesToEmojiDataKey,
} from 'virtual:mastodon-emoji-compressed';

import { unicodeToFilename } from './unicode_utils';

type UnicodeMapping = Record<
  FilenameData[number][0],
  {
    shortCode: ShortCodesToEmojiDataKey;
    filename: FilenameData[number][number];
  }
>;

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
  // filename name can be derived from unicodeToFilename
  const filename = emojiMapData[1] ?? unicodeToFilename(native);
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
