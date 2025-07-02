import { flattenEmojiData, SUPPORTED_LOCALES } from 'emojibase';
import emojiEnData from 'emojibase-data/en/compact.json';
import emojiFrData from 'emojibase-data/fr/compact.json';

import { toSupportedLocale, unicodeToLocaleLabel } from './locale';

describe('unicodeToLocaleLabel', () => {
  const emojiTestCases = [
    '1F3CB-1F3FF-200D-2640-FE0F', // 🏋🏿‍♀️ Woman weightlifter, dark skin
    '1F468-1F3FB', // 👨🏻 Man, light skin
    '1F469-1F3FB-200D-2695-FE0F', // 👩🏻‍⚕️ Woman health worker, light skin
    '1F468-1F3FD-200D-1F692', // 👨🏽‍🚒 Man firefighter, medium skin
    '1F469-1F3FE', // 👩🏾 Woman, medium-dark skin
    '1F469-1F3FF-200D-1F4BB', // 👩🏿‍💻 Woman technologist, dark skin
    '1F478-1F3FF', // 👸🏿 Princess with dark skin tone
    '1F935-1F3FC-200D-2640-FE0F', // 🤵🏼‍♀️ Woman in tuxedo, medium-light skin
    '1F9D1-1F3FC', // 🧑🏼 Person, medium-light skin
    '1F9D4-1F3FE', // 🧔🏾 Person with beard, medium-dark skin
  ];

  const flattenedEnData = flattenEmojiData(emojiEnData);
  const flattenedFrData = flattenEmojiData(emojiFrData);

  const emojiTestEnLabels = new Map(
    emojiTestCases.map((code) => [
      code,
      flattenedEnData.find((emoji) => emoji.hexcode === code)?.label,
    ]),
  );
  const emojiTestFrLabels = new Map(
    emojiTestCases.map((code) => [
      code,
      flattenedFrData.find((emoji) => emoji.hexcode === code)?.label,
    ]),
  );

  test.for(
    emojiTestCases.flatMap((code) => [
      [code, 'en', emojiTestEnLabels.get(code)],
      [code, 'fr', emojiTestFrLabels.get(code)],
    ]) satisfies [string, string, string | undefined][],
  )(
    'returns correct label for %s for %s locale',
    async ([unicodeHex, locale, expectedLabel]) => {
      const label = await unicodeToLocaleLabel(unicodeHex, locale);
      expect(label).toBe(expectedLabel);
    },
  );
});

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
