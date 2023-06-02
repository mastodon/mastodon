export type FilenameData = string[];
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
