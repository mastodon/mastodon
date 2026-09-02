import type { Locale } from 'emojibase';
import { SUPPORTED_LOCALES } from 'emojibase';

import { EMOJI_DB_NAME_SHORTCODES, EMOJI_TYPE_CUSTOM } from './constants';
import type { CacheKey, LocaleWithShortcodes } from './types';

export function toSupportedLocale(localeBase: string): Locale {
  const locale = localeBase.toLowerCase();
  if (isSupportedLocale(locale)) {
    return locale;
  }
  return 'en'; // Default to English if unsupported
}

export function toValidCacheKey(input: string): CacheKey {
  const lower = input.toLowerCase();
  if (lower === EMOJI_TYPE_CUSTOM || lower === EMOJI_DB_NAME_SHORTCODES) {
    return lower;
  }

  if (isLocaleWithShortcodes(lower)) {
    return lower;
  }

  return toSupportedLocale(lower);
}

export function localeToSegmenter(locale: Locale): Intl.Segmenter | null {
  if (typeof Intl.Segmenter === 'function') {
    return new Intl.Segmenter(locale, { granularity: 'word' });
  }
  return null;
}

function isSupportedLocale(locale: string): locale is Locale {
  return SUPPORTED_LOCALES.includes(locale as Locale);
}

function isLocaleWithShortcodes(input: string): input is LocaleWithShortcodes {
  const [baseLocale, shortcodes] = input.split('-');
  return (
    !!baseLocale &&
    !!shortcodes &&
    isSupportedLocale(baseLocale) &&
    shortcodes === EMOJI_DB_NAME_SHORTCODES
  );
}
