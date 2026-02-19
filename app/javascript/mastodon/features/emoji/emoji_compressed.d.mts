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
type Skins = null;

type Filename = string;
type UnicodeFilename = string;
export type FilenameData = [
  filename: Filename,
  unicodeFilename?: UnicodeFilename,
][];
export type ShortCodesToEmojiDataKey =
  | EmojiData['id']
  | BaseEmoji['native']
  | keyof NimbleEmojiIndex['emojis'];

type SearchData = [
  BaseEmoji['native'],
  Emoji['short_names'],
  Search,
  Emoji['unified'],
];

export type ShortCodesToEmojiData = Record<
  ShortCodesToEmojiDataKey,
  [FilenameData, SearchData]
>;
type EmojisWithoutShortCodes = FilenameData;

type EmojiCompressed = [
  ShortCodesToEmojiData,
  Skins,
  Category[],
  Data['aliases'],
  EmojisWithoutShortCodes,
];

/*
 * `emoji_compressed.js` uses `babel-plugin-preval`, which makes it difficult to convert to TypeScript.
 * As a temporary solution, we are allowing a default export here to apply the TypeScript type `EmojiCompressed` to the JS file export.
 * - {@link app/javascript/mastodon/features/emoji/emoji_compressed.js}
 */
declare const emojiCompressed: EmojiCompressed;

export default emojiCompressed; // eslint-disable-line import/no-default-export
