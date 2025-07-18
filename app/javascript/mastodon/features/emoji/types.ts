import type { FlatCompactEmoji, Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import type {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
  EMOJI_STATE_MISSING,
  EMOJI_TYPE_CUSTOM,
  EMOJI_TYPE_UNICODE,
} from './constants';

export type EmojiMode =
  | typeof EMOJI_MODE_NATIVE
  | typeof EMOJI_MODE_NATIVE_WITH_FLAGS
  | typeof EMOJI_MODE_TWEMOJI;

export type LocaleOrCustom = Locale | typeof EMOJI_TYPE_CUSTOM;

export interface EmojiAppState {
  locales: Locale[];
  currentLocale: Locale;
  mode: EmojiMode;
}

export interface UnicodeEmojiToken {
  type: typeof EMOJI_TYPE_UNICODE;
  code: string;
}
export interface CustomEmojiToken {
  type: typeof EMOJI_TYPE_CUSTOM;
  code: string;
}
export type EmojiToken = UnicodeEmojiToken | CustomEmojiToken;

export type CustomEmojiData = ApiCustomEmojiJSON;
export type UnicodeEmojiData = FlatCompactEmoji;
export type AnyEmojiData = CustomEmojiData | UnicodeEmojiData;

export type EmojiStateMissing = typeof EMOJI_STATE_MISSING;
export interface EmojiStateUnicode {
  type: typeof EMOJI_TYPE_UNICODE;
  data: UnicodeEmojiData;
}
export interface EmojiStateCustom {
  type: typeof EMOJI_TYPE_CUSTOM;
  data: CustomEmojiData;
}
export type EmojiState =
  | EmojiStateMissing
  | EmojiStateUnicode
  | EmojiStateCustom;
export type EmojiLoadedState = EmojiStateUnicode | EmojiStateCustom;

export type EmojiStateMap = Map<string, EmojiState>;

export type ExtraCustomEmojiMap = Record<string, ApiCustomEmojiJSON>;

export interface TwemojiBorderInfo {
  hexCode: string;
  hasLightBorder: boolean;
  hasDarkBorder: boolean;
}
