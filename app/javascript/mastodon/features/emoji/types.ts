import type { List as ImmutableList } from 'immutable';

import type { FlatCompactEmoji, Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import type { CustomEmoji } from '@/mastodon/models/custom_emoji';

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
  darkTheme: boolean;
}

export type EmojiType = typeof EMOJI_TYPE_UNICODE | typeof EMOJI_TYPE_CUSTOM;

export type CustomEmojiData = ApiCustomEmojiJSON;
export type UnicodeEmojiData = FlatCompactEmoji;
export type AnyEmojiData = CustomEmojiData | UnicodeEmojiData;

export interface EmojiStateUnicode {
  type: typeof EMOJI_TYPE_UNICODE;
  code: UnicodeEmojiData['hexcode'];
  data?: UnicodeEmojiData;
}
export interface EmojiStateCustom {
  type: typeof EMOJI_TYPE_CUSTOM;
  code: CustomEmojiRenderFields['shortcode'];
  data?: CustomEmojiRenderFields;
}

export type EmojiStateMissing = typeof EMOJI_STATE_MISSING;
export type EmojiLoadedState = Required<EmojiStateUnicode | EmojiStateCustom>;
export type EmojiStateToken = Exclude<EmojiState, EmojiStateMissing>;

export type EmojiState =
  | EmojiStateMissing
  | EmojiStateUnicode
  | EmojiStateCustom;

export type CustomEmojiMapArg =
  | ExtraCustomEmojiMap
  | ImmutableList<CustomEmoji>;
export type CustomEmojiRenderFields = Pick<
  CustomEmojiData,
  'shortcode' | 'static_url' | 'url'
>;
export type ExtraCustomEmojiMap = Record<string, CustomEmojiRenderFields>;
