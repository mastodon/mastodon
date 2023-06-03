// The output of this module is designed to mimic emoji-mart's
// "data" object, such that we can use it for a light version of emoji-mart's
// emojiIndex.search functionality.
import type {
  Native,
  Search,
  ShortCodesToEmojiData,
  ShortName,
  Unified,
} from './emoji_compressed';
import emojiCompressed from './emoji_compressed';
import { unicodeToUnifiedName } from './unicode_to_unified_name';

type Emojis = {
  [key in keyof ShortCodesToEmojiData]: {
    native: Native;
    search: Search;
    short_names: ShortName[];
    unified: Unified;
  };
};

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const [shortCodesToEmojiData, skins, categories, aliases, short_names] =
  emojiCompressed;

const emojis: Emojis = {};

// decompress
Object.keys(shortCodesToEmojiData).forEach((shortCode) => {
  const [
    filenameData, // eslint-disable-line @typescript-eslint/no-unused-vars
    searchData,
  ] = shortCodesToEmojiData[shortCode];
  const native = searchData[0];
  let short_names = searchData[1];
  const search = searchData[2];
  let unified = searchData[3];

  if (!unified) {
    // unified name can be derived from unicodeToUnifiedName
    unified = unicodeToUnifiedName(native);
  }

  short_names = [shortCode].concat(short_names);
  emojis[shortCode] = {
    native,
    search,
    short_names,
    unified,
  };
});

export { emojis, skins, categories, short_names };
