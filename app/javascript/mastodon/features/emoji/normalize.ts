import { isList } from 'immutable';

import type { CompactEmoji, SkinTone } from 'emojibase';
import { fromHexcodeToCodepoint } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import {
  VARIATION_SELECTOR_CODE,
  KEYCAP_CODE,
  EMOJIS_WITH_DARK_BORDER,
  EMOJIS_WITH_LIGHT_BORDER,
  EMOJIS_REQUIRING_INVERSION_IN_LIGHT_MODE,
  EMOJIS_REQUIRING_INVERSION_IN_DARK_MODE,
  EMOJI_MIN_TOKEN_LENGTH,
} from './constants';
import type {
  CustomEmojiData,
  CustomEmojiMapArg,
  ExtraCustomEmojiMap,
  UnicodeEmojiData,
} from './types';
import { emojiToUnicodeHex } from './utils';

const SKIN_TONE_MAP: Record<number, SkinTone> = {
  0x1f3fb: 1, // Light skin tone
  0x1f3fc: 2, // Medium-light skin tone
  0x1f3fd: 3, // Medium skin tone
  0x1f3fe: 4, // Medium-dark skin tone
  0x1f3ff: 5, // Dark skin tone
};

export function transformEmojiData(
  emoji: CompactEmoji,
  segmenter: Intl.Segmenter | null,
): UnicodeEmojiData {
  const {
    shortcodes = [],
    tags = [],
    label,
    emoticon,
    hexcode,
    unicode,
    group,
    order,
    skins = [],
  } = emoji;
  const extract = (str: string) => extractTokens(str, segmenter);

  let normalizedEmoticons: string[] | undefined = undefined;
  if (emoticon) {
    normalizedEmoticons = Array.isArray(emoticon) ? emoticon : [emoticon];
  }

  const tokens = [
    ...new Set([
      ...shortcodes.map(extract).flat(),
      ...tags.map(extract).flat(),
      ...extract(label),
      ...(normalizedEmoticons ?? []),
    ]),
  ].sort((a, b) => a.localeCompare(b));

  const res: UnicodeEmojiData = {
    tokens,
    shortcodes,
    label,
    emoticons: normalizedEmoticons,
    hexcode,
    unicode,
    group,
    order,
  };

  for (const skin of skins) {
    res.skinHexcodes ??= [];
    res.skinHexcodes.push(skin.hexcode);

    res.skinTones ??= [];
    for (const codePoint of skin.unicode) {
      const tone = SKIN_TONE_MAP[codePoint.codePointAt(0) ?? 0];
      if (tone) {
        res.skinTones.push(tone);
        break;
      }
    }
  }

  return res;
}

export function transformCustomEmojiData(
  emoji: ApiCustomEmojiJSON,
): CustomEmojiData {
  const tokens = emoji.shortcode
    .split('_')
    .filter((word) => word.length >= EMOJI_MIN_TOKEN_LENGTH)
    .map((word) => word.toLowerCase());
  return {
    ...emoji,
    tokens,
  };
}

export function skinHexcodeToEmoji(
  skinHexcode: string,
  emoji: UnicodeEmojiData,
): UnicodeEmojiData {
  return {
    ...emoji,
    unicode: String.fromCodePoint(...fromHexcodeToCodepoint(skinHexcode)),
    hexcode: skinHexcode,
  };
}

// Misc codes that have special handling
const EYE_CODE = 0x1f441;
const SPEECH_BUBBLE_CODE = 0x1f5e8;

export function unicodeToTwemojiHex(unicodeHex: string): string {
  const codes = fromHexcodeToCodepoint(unicodeHex);
  const normalizedCodes: number[] = [];
  for (let i = 0; i < codes.length; i++) {
    const code = codes[i];
    if (!code) {
      continue;
    }
    // Some emoji have their variation selector removed
    if (code === VARIATION_SELECTOR_CODE) {
      // Key emoji
      if (i === 1 && codes.at(-1) === KEYCAP_CODE) {
        continue;
      }
      // Eye in speech bubble
      if (codes.at(0) === EYE_CODE && codes.at(-2) === SPEECH_BUBBLE_CODE) {
        continue;
      }
    }
    // This removes zero padding to correctly match the SVG filenames
    normalizedCodes.push(code);
  }

  return normalizedCodes
    .map((code) => code.toString(16))
    .join('-')
    .toLowerCase();
}

const CODES_WITH_DARK_BORDER = EMOJIS_WITH_DARK_BORDER.map(emojiToUnicodeHex);

const CODES_WITH_LIGHT_BORDER = EMOJIS_WITH_LIGHT_BORDER.map(emojiToUnicodeHex);

export function unicodeHexToUrl({
  unicodeHex,
  darkTheme,
  assetHost,
}: {
  unicodeHex: string;
  darkTheme: boolean;
  assetHost: string;
}): string {
  const normalizedHex = unicodeToTwemojiHex(unicodeHex);
  let url = `${assetHost}/emoji/${normalizedHex}`;
  if (darkTheme && CODES_WITH_LIGHT_BORDER.includes(normalizedHex)) {
    url += '_border';
  }
  if (CODES_WITH_DARK_BORDER.includes(normalizedHex)) {
    url += '_border';
  }
  url += '.svg';
  return url;
}

export function emojiToInversionClassName(emoji: string): string | null {
  if (EMOJIS_REQUIRING_INVERSION_IN_DARK_MODE.includes(emoji)) {
    return 'invert-on-dark';
  }
  if (EMOJIS_REQUIRING_INVERSION_IN_LIGHT_MODE.includes(emoji)) {
    return 'invert-on-light';
  }
  return null;
}

export function cleanExtraEmojis(extraEmojis?: CustomEmojiMapArg | null) {
  if (!extraEmojis) {
    return null;
  }
  if (Array.isArray(extraEmojis)) {
    return extraEmojis.reduce<ExtraCustomEmojiMap>(
      (acc, emoji) => ({ ...acc, [emoji.shortcode]: emoji }),
      {},
    );
  }
  if (isList(extraEmojis)) {
    return extraEmojis
      .toJS()
      .reduce<ExtraCustomEmojiMap>(
        (acc, emoji) => ({ ...acc, [emoji.shortcode]: emoji }),
        {},
      );
  }
  return extraEmojis;
}

/**
 * Tokenizes an input string into words, using Intl.Segmenter if available.
 * @param input Any input string.
 * @param segmenter Segmenter, if available.
 * @returns Array of tokens in lowercase.
 */
export function extractTokens(
  input: string,
  segmenter: Intl.Segmenter | null,
): string[] {
  if (!input.trim()) {
    return [];
  }
  const tokens: string[] = [];

  // Prefer to use Intl.Segmenter if available for better locale support.
  if (segmenter) {
    for (const { isWordLike, segment } of segmenter.segment(
      input.replaceAll('_', ' '), // Handle underscores from shortcodes.
    )) {
      if (isWordLike && segment.length >= EMOJI_MIN_TOKEN_LENGTH) {
        tokens.push(segment.toLowerCase());
      }
    }
  } else {
    // Fallback to simple splitting.
    input.split(/[\s_-]+/).forEach((word) => {
      if (/\w/.test(word) && word.length >= EMOJI_MIN_TOKEN_LENGTH) {
        tokens.push(word.toLowerCase());
      }
    });
  }
  return tokens;
}
