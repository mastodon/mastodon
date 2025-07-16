import type { FlatCompactEmoji, Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import type {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
} from './constants';

export type EmojiMode =
  | typeof EMOJI_MODE_NATIVE
  | typeof EMOJI_MODE_NATIVE_WITH_FLAGS
  | typeof EMOJI_MODE_TWEMOJI;

export type LocaleOrCustom = Locale | 'custom';

export type CustomEmoji = ApiCustomEmojiJSON;
export type UnicodeEmoji = FlatCompactEmoji;
export type AnyEmoji = CustomEmoji | UnicodeEmoji;

export interface CustomEmojiToken {
  type: 'custom';
  code: string;
}
export interface UnicodeEmojiToken {
  type: 'unicode';
  code: string;
}
export type EmojiToken = CustomEmojiToken | UnicodeEmojiToken;

export interface TwemojiBorderInfo {
  hexCode: string;
  hasLightBorder: boolean;
  hasDarkBorder: boolean;
}
