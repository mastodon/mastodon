import EMOJI_REGEX from 'emojibase-regex/emoji-loose';

export function stringHasUnicodeEmoji(text: string): boolean {
  return EMOJI_REGEX.test(text);
}

// From https://github.com/talkjs/country-flag-emoji-polyfill/blob/master/src/index.ts#L49-L50
const EMOJIS_FLAGS_REGEX =
  /[\u{1F1E6}-\u{1F1FF}|\u{E0062}-\u{E0063}|\u{E0065}|\u{E0067}|\u{E006C}|\u{E006E}|\u{E0073}-\u{E0074}|\u{E0077}|\u{E007F}]+/u;

export function stringHasUnicodeFlags(text: string): boolean {
  return EMOJIS_FLAGS_REGEX.test(text);
}
