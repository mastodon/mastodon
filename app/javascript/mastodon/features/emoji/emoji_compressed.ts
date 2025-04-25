import type { BaseEmoji } from 'emoji-mart';
import type { Category, Data, Emoji } from 'emoji-mart/dist-es/utils/data';

import compressed from './emoji_compressed.json';

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
type Skins = null;

type Filename = string;
type UnicodeFilename = string;
export type FilenameTuple = [
  filename: Filename,
  unicodeFilename?: UnicodeFilename,
];
export type FilenameData = FilenameTuple[];

export type SearchData = [
  BaseEmoji['native'],
  Emoji['short_names'],
  Search,
  Emoji['unified'],
];

export type ShortCodesToEmojiKey = string;
export type ShortCodesToEmojiMap = Record<
  ShortCodesToEmojiKey,
  [FilenameData, SearchData]
>;

export type EmojiCompressed = [
  ShortCodesToEmojiMap,
  Skins,
  Category[],
  Data['aliases'],
  FilenameData,
  Data,
];

// eslint-disable-next-line import/no-default-export
export default compressed as EmojiCompressed;
