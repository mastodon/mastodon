// The output of this module is designed to mimic emoji-mart's
// "data" object, such that we can use it for a light version of emoji-mart's
// emojiIndex.search functionality.
import emojiCompressed_ from './emoji_compressed';
import { unicodeToUnifiedName } from './unicode_to_unified_name';

type FilenameData = string[];
type Native = string;
type ShortName = string;
type Search = string;
type Unified = string;

type SearchData = [Native, ShortName[], Search, Unified];

interface ShortCodesToEmojiData {
  [key: string]: [FilenameData, SearchData];
}
type Skins = null;
interface Category {
  id: string;
  name: string;
  emojis: string[];
}

type Emojis = {
  [key in keyof ShortCodesToEmojiData]: {
    native: Native;
    search: Search;
    short_names: ShortName[];
    unified: Unified;
  };
};

const emojiCompressed = emojiCompressed_ as [
  ShortCodesToEmojiData,
  Skins,
  Category[],
  ShortName[]
];
const [shortCodesToEmojiData, skins, categories, short_names] = emojiCompressed;

const emojis: Emojis = {};

// decompress
Object.keys(shortCodesToEmojiData).forEach((shortCode) => {
  const [
    filenameData, // eslint-disable-line @typescript-eslint/no-unused-vars
    searchData,
  ] = shortCodesToEmojiData[shortCode];
  let [native, short_names, search, unified] = searchData; // eslint-disable-line prefer-const

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
