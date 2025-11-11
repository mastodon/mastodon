// The output of this module is designed to mimic emoji-mart's
// "data" object, such that we can use it for a light version of emoji-mart's
// emojiIndex.search functionality.
import type { BaseEmoji } from 'emoji-mart';
import type { Emoji } from 'emoji-mart/dist-es/utils/data';
import emojiCompressed from 'virtual:mastodon-emoji-compressed';
import type {
  Search,
  ShortCodesToEmojiData,
} from 'virtual:mastodon-emoji-compressed';

import { unicodeToUnifiedName } from './unicode_utils';

type Emojis = Record<
  NonNullable<keyof ShortCodesToEmojiData>,
  {
    native: BaseEmoji['native'];
    search: Search;
    short_names: Emoji['short_names'];
    unified: Emoji['unified'];
  }
>;

const [
  shortCodesToEmojiData,
  _skins,
  categories,
  short_names,
  _emojisWithoutShortCodes,
] = emojiCompressed;

const emojis: Emojis = {};

// decompress
Object.keys(shortCodesToEmojiData).forEach((shortCode) => {
  const emojiData = shortCodesToEmojiData[shortCode];
  if (!emojiData) return;

  const [_filenameData, searchData] = emojiData;
  const [native, short_names, search, unified] = searchData;

  emojis[shortCode] = {
    native,
    search,
    short_names: short_names ? [shortCode].concat(short_names) : undefined,
    unified: unified ?? unicodeToUnifiedName(native),
  };
});

export { emojis, categories, short_names };
