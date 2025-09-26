import type { List as ImmutableList } from 'immutable';

import type { FlatCompactEmoji, Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import type { CustomEmoji } from '@/mastodon/models/custom_emoji';
import type { LimitedCache } from '@/mastodon/utils/cache';

import type {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
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
  darkTheme: boolean;
}

export type CustomEmojiData = ApiCustomEmojiJSON;
export type UnicodeEmojiData = FlatCompactEmoji;
export type AnyEmojiData = CustomEmojiData | UnicodeEmojiData;

type CustomEmojiRenderFields = Pick<
  CustomEmojiData,
  'shortcode' | 'static_url' | 'url'
>;

export interface EmojiStateUnicode {
  type: typeof EMOJI_TYPE_UNICODE;
  code: string;
  data?: UnicodeEmojiData;
}
export interface EmojiStateCustom {
  type: typeof EMOJI_TYPE_CUSTOM;
  code: string;
  data?: CustomEmojiRenderFields;
}
export type EmojiState = EmojiStateUnicode | EmojiStateCustom;
export type EmojiLoadedState =
  | Required<EmojiStateUnicode>
  | Required<EmojiStateCustom>;

export type EmojiStateMap = LimitedCache<string, EmojiState>;

export type CustomEmojiMapArg =
  | ExtraCustomEmojiMap
  | ImmutableList<CustomEmoji>;

export type ExtraCustomEmojiMap = Record<
  string,
  Pick<CustomEmojiData, 'shortcode' | 'static_url' | 'url'>
>;

export interface TwemojiBorderInfo {
  hexCode: string;
  hasLightBorder: boolean;
  hasDarkBorder: boolean;
}
