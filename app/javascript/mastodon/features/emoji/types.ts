import type { List as ImmutableList } from 'immutable';

import type { CompactEmoji, Locale, SkinTone } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import type { CustomEmoji } from '@/mastodon/models/custom_emoji';
import type { RequiredExcept } from '@/mastodon/utils/types';

import type {
  EMOJI_DB_NAME_SHORTCODES,
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
export type LocaleWithShortcodes = `${Locale}-shortcodes`;
export type CacheKey =
  | LocaleOrCustom
  | typeof EMOJI_DB_NAME_SHORTCODES
  | LocaleWithShortcodes;

export interface EmojiAppState {
  locales: Locale[];
  currentLocale: Locale;
  mode: EmojiMode;
  darkTheme: boolean;
  assetHost: string;
}

export type CustomEmojiData = ApiCustomEmojiJSON & { tokens: string[] };
export interface UnicodeEmojiData extends Omit<
  CompactEmoji,
  'emoticon' | 'skins' | 'tags'
> {
  shortcodes: string[];
  tokens: string[];
  emoticons?: string[];
  skinHexcodes?: string[];
  skinTones?: (SkinTone | SkinTone[])[];
}
export type AnyEmojiData = CustomEmojiData | UnicodeEmojiData;

type CustomEmojiRenderFields = Pick<
  CustomEmojiData,
  'shortcode' | 'static_url' | 'url'
>;

export interface EmojiStateUnicode {
  type: typeof EMOJI_TYPE_UNICODE;
  code: string;
  data?: UnicodeEmojiData;
  shortcode?: string;
}
export interface EmojiStateCustom {
  type: typeof EMOJI_TYPE_CUSTOM;
  code: string;
  data?: CustomEmojiRenderFields;
}
export type EmojiState = EmojiStateUnicode | EmojiStateCustom;

export type EmojiLoadedState =
  | RequiredExcept<EmojiStateUnicode, 'shortcode'>
  | Required<EmojiStateCustom>;

export type CustomEmojiMapArg =
  | ExtraCustomEmojiMap
  | ImmutableList<CustomEmoji>
  | CustomEmoji[]
  | ApiCustomEmojiJSON[];

export type ExtraCustomEmojiMap = Record<
  string,
  Pick<CustomEmojiData, 'shortcode' | 'static_url' | 'url'>
>;
