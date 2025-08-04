import debug from 'debug';

import { emojiRegexPolyfill } from '@/mastodon/polyfills';

export function emojiLogger(segment: string) {
  return debug(`emojis:${segment}`);
}

export function stringHasUnicodeEmoji(input: string): boolean {
  return new RegExp(EMOJI_REGEX, supportedFlags()).test(input);
}

export function stringHasUnicodeFlags(input: string): boolean {
  if (supportsRegExpSets()) {
    return new RegExp(
      '\\p{RGI_Emoji_Flag_Sequence}|\\p{RGI_Emoji_Tag_Sequence}',
      'v',
    ).test(input);
  }
  return new RegExp(
    // First range is regional indicator symbols,
    // Second is a black flag + 0-9|a-z tag chars + cancel tag.
    // See: https://en.wikipedia.org/wiki/Regional_indicator_symbol
    '(?:\uD83C[\uDDE6-\uDDFF]){2}|\uD83C\uDFF4(?:\uDB40[\uDC30-\uDC7A])+\uDB40\uDC7F',
  ).test(input);
}

// Constant as this is supported by all browsers.
const CUSTOM_EMOJI_REGEX = /:([a-z0-9_]+):/i;
export function stringHasCustomEmoji(input: string) {
  return CUSTOM_EMOJI_REGEX.test(input);
}

export function stringHasAnyEmoji(input: string) {
  return stringHasUnicodeEmoji(input) || stringHasCustomEmoji(input);
}

export function anyEmojiRegex() {
  return new RegExp(
    `${EMOJI_REGEX}|${CUSTOM_EMOJI_REGEX.source}`,
    supportedFlags('gi'),
  );
}

function supportsRegExpSets() {
  return 'unicodeSets' in RegExp.prototype;
}

function supportedFlags(flags = '') {
  if (supportsRegExpSets()) {
    return `${flags}v`;
  }
  return flags;
}

const EMOJI_REGEX = emojiRegexPolyfill?.source ?? '\\p{RGI_Emoji}';
