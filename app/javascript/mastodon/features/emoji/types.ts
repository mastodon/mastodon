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

export type CustomEmojiData = ApiCustomEmojiJSON;
export type UnicodeEmojiData = FlatCompactEmoji;
export type AnyEmojiData = CustomEmojiData | UnicodeEmojiData;

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

// Type Guards

export function isUnicodeEmojiData(data: unknown): data is UnicodeEmojiData {
  return (
    typeof data === 'object' &&
    !!data &&
    'hexcode' in data &&
    typeof data.hexcode === 'string'
  );
}

export function isCustomEmojiData(data: unknown): data is CustomEmojiData {
  return (
    typeof data === 'object' &&
    !!data &&
    'static_url' in data &&
    typeof data.static_url === 'string'
  );
}
