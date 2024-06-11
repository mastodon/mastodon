// The output of this module is designed to mimic emoji-mart's
// "data" object, such that we can use it for a light version of emoji-mart's
// emojiIndex.search functionality.
import type { BaseEmoji } from 'emoji-mart';
import type { Emoji } from 'emoji-mart/dist-es/utils/data';

import type { Search, ShortCodesToEmojiData } from './emoji_compressed';
import emojiCompressed from './emoji_compressed';
import { unicodeToUnifiedName } from './unicode_to_unified_name';

type Emojis = {
  [key in NonNullable<keyof ShortCodesToEmojiData>]: {
    native: BaseEmoji['native'];
    search: Search;
    short_names: Emoji['short_names'];
    unified: Emoji['unified'];
  };
};

const [
  shortCodesToEmojiData,
  skins,
  categories,
  short_names,
  _emojisWithoutShortCodes,
] = emojiCompressed;

const emojis: Emojis = {};

// decompress
Object.keys(shortCodesToEmojiData).forEach((shortCode) => {
  const [_filenameData, searchData] = shortCodesToEmojiData[shortCode];
  const native = searchData[0];
  let short_names = searchData[1];
  const search = searchData[2];
  let unified = searchData[3];

  if (!unified) {
    // unified name can be derived from unicodeToUnifiedName
    unified = unicodeToUnifiedName(native);
  }

  if (short_names) short_names = [shortCode].concat(short_names);
  emojis[shortCode] = {
    native,
    search,
    short_names,
    unified,
  };
});

export { emojis, skins, categories, short_names };
