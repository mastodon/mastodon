import debug from 'debug';

import { emojiRegexPolyfill } from '@/mastodon/polyfills';

import { VARIATION_SELECTOR_CODE } from './constants';

export function emojiLogger(segment: string) {
  return debug(`emojis:${segment}`);
}

export function isUnicodeEmoji(input: string): boolean {
  return (
    input.length > 0 &&
    new RegExp(`^(${EMOJI_REGEX})+$`, supportedFlags()).test(input)
  );
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
// Use the polyfill regex or the Unicode property escapes if supported.
const EMOJI_REGEX = emojiRegexPolyfill?.source ?? '\\p{RGI_Emoji}';

export function isCustomEmoji(input: string): boolean {
  return new RegExp(`^${CUSTOM_EMOJI_REGEX.source}$`, 'i').test(input);
}

export function anyEmojiRegex() {
  return new RegExp(
    `${EMOJI_REGEX}|${CUSTOM_EMOJI_REGEX.source}`,
    supportedFlags('gi'),
  );
}

export function emojiToUnicodeHex(emoji: string): string {
  const codes: string[] = [];
  for (const char of emoji) {
    const code = char.codePointAt(0);
    if (code !== undefined) {
      codes.push(code.toString(16).toUpperCase().padStart(4, '0'));
    }
  }

  // Handles how Emojibase removes the variation selector for single code emojis.
  // See: https://emojibase.dev/docs/spec/#merged-variation-selectors
  if (
    codes.at(1) === VARIATION_SELECTOR_CODE.toString(16).toUpperCase() &&
    codes.length === 2
  ) {
    codes.pop();
  }

  return codes.join('-');
}

const CHARS_ALLOWED_AROUND_EMOJI =
  // eslint-disable-next-line no-control-regex
  /[>< …\u0009-\u000d\u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]/;

// TODO: Move to picker file when that's being built out.
export function insertEmojiAtPosition(
  text: string,
  emoji: string,
  position = text.length,
): string {
  const isShortcode = isCustomEmoji(emoji);
  const needsSpace =
    isShortcode &&
    position > 0 &&
    !CHARS_ALLOWED_AROUND_EMOJI.test(text[position - 1] ?? '');
  return `${text.slice(0, position)}${needsSpace ? ' ' : ''}${emoji} ${text.slice(position)}`;
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
