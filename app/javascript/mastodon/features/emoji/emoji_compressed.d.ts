export type FilenameData = string[][];
export type Native = string;
export type ShortName = string;
export type Search = string;
export type Unified = string;

export type SearchData = [Native, ShortName[], Search, Unified];

export interface ShortCodesToEmojiData {
  [key: string]: [FilenameData, SearchData];
}
export type Skins = null;
export interface Category {
  id: string;
  name: string;
  emojis: string[];
}

export type EmojiCompressed = [
  ShortCodesToEmojiData,
  Skins,
  Category[],
  ShortName[]
];

// Because emoji_compressed.js is difficult to change to TS,
// export we are temporarily allowing a default export
// at this location to apply the TS type to the JS file export.
declare const emojiCompressed: EmojiCompressed;

export default emojiCompressed; // eslint-disable-line import/no-default-export
