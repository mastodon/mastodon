import { isList } from 'immutable';

import { fromHexcodeToCodepoint } from 'emojibase';

import { assetHost } from '@/mastodon/utils/config';

import {
  VARIATION_SELECTOR_CODE,
  KEYCAP_CODE,
  EMOJIS_WITH_DARK_BORDER,
  EMOJIS_WITH_LIGHT_BORDER,
  EMOJIS_REQUIRING_INVERSION_IN_LIGHT_MODE,
  EMOJIS_REQUIRING_INVERSION_IN_DARK_MODE,
  EMOJI_MIN_TOKEN_LENGTH,
} from './constants';
import { toSupportedLocale } from './locale';
import type { CustomEmojiMapArg, ExtraCustomEmojiMap } from './types';
import { emojiToUnicodeHex } from './utils';

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

export function unicodeHexToUrl(unicodeHex: string, darkMode: boolean): string {
  const normalizedHex = unicodeToTwemojiHex(unicodeHex);
  let url = `${assetHost}/emoji/${normalizedHex}`;
  if (darkMode && CODES_WITH_LIGHT_BORDER.includes(normalizedHex)) {
    url += '_border';
  }
  if (CODES_WITH_DARK_BORDER.includes(normalizedHex)) {
    url += '_border';
  }
  url += '.svg';
  return url;
}

let segmenter: Intl.Segmenter | null = null;

/**
 * Tokenizes an input string into words, using Intl.Segmenter if available.
 * @param input Any input string.
 * @param localeString Locale string to use for segmentation.
 * @returns Array of tokens in lowercase.
 */
export function extractTokens(input: string, localeString: string): string[] {
  if (!input.trim()) {
    return [];
  }
  const tokens: string[] = [];

  // Prefer to use Intl.Segmenter if available for better locale support.
  if (typeof Intl.Segmenter === 'function') {
    const locale = toSupportedLocale(localeString);
    segmenter ??= new Intl.Segmenter(locale, { granularity: 'word' });

    for (const { isWordLike, segment } of segmenter.segment(
      input.replaceAll('_', ' '), // Handle underscores from shortcodes.
    )) {
      if (isWordLike && segment.length > EMOJI_MIN_TOKEN_LENGTH) {
        tokens.push(segment.toLowerCase());
      }
    }
  } else {
    // Fallback to simple splitting.
    input.split(/[\s_-]+/).forEach((word) => {
      if (/\w/.test(word) && word.length > EMOJI_MIN_TOKEN_LENGTH) {
        tokens.push(word.toLowerCase());
      }
    });
  }
  return tokens;
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

export function cleanExtraEmojis(extraEmojis?: CustomEmojiMapArg) {
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
