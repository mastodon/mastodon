import {
  ANY_EMOJI_REGEX,
  CUSTOM_EMOJI_REGEX,
  EMOJIS_FLAGS_REGEX,
  UNICODE_EMOJI_REGEX,
} from './constants';

export function stringHasUnicodeEmoji(input: string): boolean {
  return UNICODE_EMOJI_REGEX.test(input);
}

export function stringHasUnicodeFlags(input: string): boolean {
  return EMOJIS_FLAGS_REGEX.test(input);
}

export function stringHasCustomEmoji(input: string) {
  return CUSTOM_EMOJI_REGEX.test(input);
}

export function stringHasAnyEmoji(input: string) {
  return ANY_EMOJI_REGEX.test(input);
}
