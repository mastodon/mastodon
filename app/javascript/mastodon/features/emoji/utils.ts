import debug from 'debug';

import {
  CUSTOM_EMOJI_REGEX,
  UNICODE_EMOJI_REGEX,
  UNICODE_FLAG_EMOJI_REGEX,
} from './constants';

export function emojiLogger(segment: string) {
  return debug(`emojis:${segment}`);
}

export function stringHasUnicodeEmoji(input: string): boolean {
  return UNICODE_EMOJI_REGEX.test(input);
}

export function stringHasUnicodeFlags(input: string): boolean {
  return UNICODE_FLAG_EMOJI_REGEX.test(input);
}

export function stringHasCustomEmoji(input: string) {
  return CUSTOM_EMOJI_REGEX.test(input);
}

export function stringHasAnyEmoji(input: string) {
  return stringHasUnicodeEmoji(input) || stringHasCustomEmoji(input);
}
