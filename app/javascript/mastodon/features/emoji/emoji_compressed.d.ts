import type { BaseEmoji, EmojiData, NimbleEmojiIndex } from 'emoji-mart';
import type { Category, Data, Emoji } from 'emoji-mart/dist-es/utils/data';

/*
 * The 'search' property, although not defined in the [`Emoji`]{@link node_modules/@types/emoji-mart/dist-es/utils/data.d.ts#Emoji} type,
 * is used in the application.
 * This could be due to an oversight by the library maintainer.
 * The `search` property is defined and used [here]{@link node_modules/emoji-mart/dist/utils/data.js#uncompress}.
 */
export type Search = string;
/*
 * The 'skins' property does not exist in the application data.
 * This could be a potential area of refactoring or error handling.
 * The non-existence of 'skins' property is evident at [this location]{@link app/javascript/mastodon/features/emoji/emoji_compressed.js:121}.
 */
export type Skins = null;

export type FilenameData = string[][];
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
