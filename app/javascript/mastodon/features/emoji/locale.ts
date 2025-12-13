import type { Locale } from 'emojibase';
import { SUPPORTED_LOCALES } from 'emojibase';

import type { LocaleOrCustom } from './types';

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
