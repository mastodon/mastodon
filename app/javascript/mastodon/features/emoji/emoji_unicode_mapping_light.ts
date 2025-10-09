// A mapping of unicode strings to an object containing the filename
// (i.e. the svg filename) and a shortCode intended to be shown
// as a "title" attribute in an HTML element (aka tooltip).

import emojiCompressed from 'virtual:mastodon-emoji-compressed';
import type {
  FilenameData,
  ShortCodesToEmojiDataKey,
} from 'virtual:mastodon-emoji-compressed';

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

// taken from:
// https://github.com/twitter/twemoji/blob/47732c7/twemoji-generator.js#L848-L866
function unicodeToFilename(str: string) {
  let result = '';
  let charCode = 0;
  let p = 0;
  let i = 0;
  while (i < str.length) {
    charCode = str.charCodeAt(i++);
    if (p) {
      if (result.length > 0) {
        result += '-';
      }
      result += (0x10000 + ((p - 0xd800) << 10) + (charCode - 0xdc00)).toString(
        16,
      );
      p = 0;
    } else if (0xd800 <= charCode && charCode <= 0xdbff) {
      p = charCode;
    } else {
      if (result.length > 0) {
        result += '-';
      }
      result += charCode.toString(16);
    }
  }
  return result;
}

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
