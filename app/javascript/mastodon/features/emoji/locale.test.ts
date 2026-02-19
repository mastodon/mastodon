import { SUPPORTED_LOCALES } from 'emojibase';

import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';

describe('toSupportedLocale', () => {
  test('returns the same locale if it is supported', () => {
    for (const locale of SUPPORTED_LOCALES) {
      expect(toSupportedLocale(locale)).toBe(locale);
    }
  });

  test('returns "en" for unsupported locales', () => {
    const unsupportedLocales = ['xx', 'fr-CA'];
    for (const locale of unsupportedLocales) {
      expect(toSupportedLocale(locale)).toBe('en');
    }
  });
});

describe('toSupportedLocaleOrCustom', () => {
  test('returns custom for "custom" locale', () => {
    expect(toSupportedLocaleOrCustom('custom')).toBe('custom');
  });
  test('returns supported locale for valid locales', () => {
    for (const locale of SUPPORTED_LOCALES) {
      expect(toSupportedLocaleOrCustom(locale)).toBe(locale);
    }
  });
});
