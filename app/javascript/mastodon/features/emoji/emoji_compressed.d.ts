import type { BaseEmoji, EmojiData, NimbleEmojiIndex } from 'emoji-mart';
import type { Category, Data, Emoji } from 'emoji-mart/dist-es/utils/data';

export type FilenameData = string[][];
export type Search = string;
export type ShortCodesToEmojiDataKey =
  | EmojiData['id']
  | BaseEmoji['native']
  | keyof NimbleEmojiIndex['emojis'];

export type SearchData = [
  BaseEmoji['native'],
  Emoji['short_names'],
  Search,
  Emoji['unified']
];

export interface ShortCodesToEmojiData {
  [key: ShortCodesToEmojiDataKey]: [FilenameData, SearchData];
}
export type Skins = null;

export type EmojiCompressed = [
  ShortCodesToEmojiData,
  Skins,
  Category[],
  Data['aliases'],
  Emoji['short_names']
];

// Because emoji_compressed.js is difficult to change to TS,
// export we are temporarily allowing a default export
// at this location to apply the TS type to the JS file export.
declare const emojiCompressed: EmojiCompressed;

export default emojiCompressed; // eslint-disable-line import/no-default-export
