import type { Locale } from 'emojibase';
import { SUPPORTED_LOCALES } from 'emojibase';

import { searchEmojiByHexcode } from './database';

export type LocaleOrCustom = Locale | 'custom';

export async function unicodeToLocaleLabel(
  unicodeHex: string,
  localeString: string,
) {
  const locale = toSupportedLocale(localeString);
  const emoji = await searchEmojiByHexcode(unicodeHex, locale);
  if (!emoji) {
    return null;
  }
  return emoji.label;
}

export function toSupportedLocale(localeBase: string): Locale {
  const locale = localeBase.toLowerCase();
  if (isSupportedLocale(locale)) {
    return locale;
  }
  return 'en'; // Default to English if unsupported
}

export function toSupportedLocaleOrCustom(locale: string): LocaleOrCustom {
  if (locale.toLowerCase() === 'custom') {
    return 'custom';
  }
  return toSupportedLocale(locale);
}

function isSupportedLocale(locale: string): locale is Locale {
  return SUPPORTED_LOCALES.includes(locale.toLowerCase() as Locale);
}
