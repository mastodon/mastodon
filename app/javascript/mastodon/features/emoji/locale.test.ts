import { SUPPORTED_LOCALES } from 'emojibase';

import { toSupportedLocale } from './locale';

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
