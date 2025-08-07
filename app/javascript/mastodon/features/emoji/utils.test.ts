import {
  stringHasAnyEmoji,
  stringHasCustomEmoji,
  stringHasUnicodeEmoji,
  stringHasUnicodeFlags,
} from './utils';

describe('stringHasUnicodeEmoji', () => {
  test.concurrent.for([
    ['only text', false],
    ['text with non-emoji symbols ™©', false],
    ['text with emoji 😀', true],
    ['multiple emojis 😀😃😄', true],
    ['emoji with skin tone 👍🏽', true],
    ['emoji with ZWJ 👩‍❤️‍👨', true],
    ['emoji with variation selector ✊️', true],
    ['emoji with keycap 1️⃣', true],
    ['emoji with flags 🇺🇸', true],
    ['emoji with regional indicators 🇦🇺', true],
    ['emoji with gender 👩‍⚕️', true],
    ['emoji with family 👨‍👩‍👧‍👦', true],
    ['emoji with zero width joiner 👩‍🔬', true],
    ['emoji with non-BMP codepoint 🧑‍🚀', true],
    ['emoji with combining marks 👨‍👩‍👧‍👦', true],
    ['emoji with enclosing keycap #️⃣', true],
    ['emoji with no visible glyph \u200D', false],
  ] as const)(
    'stringHasUnicodeEmoji has emojis in "%s": %o',
    ([text, expected], { expect }) => {
      expect(stringHasUnicodeEmoji(text)).toBe(expected);
    },
  );
});

describe('stringHasUnicodeFlags', () => {
  test.concurrent.for([
    ['EU 🇪🇺', true],
    ['Germany 🇩🇪', true],
    ['Canada 🇨🇦', true],
    ['São Tomé & Príncipe 🇸🇹', true],
    ['Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿', true],
    ['black flag 🏴', false],
    ['arrr 🏴‍☠️', false],
    ['rainbow flag 🏳️‍🌈', false],
    ['non-flag 🔥', false],
    ['only text', false],
  ] as const)(
    'stringHasFlags has flag in "%s": %o',
    ([text, expected], { expect }) => {
      expect(stringHasUnicodeFlags(text)).toBe(expected);
    },
  );
});

describe('stringHasCustomEmoji', () => {
  test('string with custom emoji returns true', () => {
    expect(stringHasCustomEmoji(':custom: :test:')).toBeTruthy();
  });
  test('string without custom emoji returns false', () => {
    expect(stringHasCustomEmoji('🏳️‍🌈 :🏳️‍🌈: text ™')).toBeFalsy();
  });
});

describe('stringHasAnyEmoji', () => {
  test('string without any emoji or characters', () => {
    expect(stringHasAnyEmoji('normal text. 12356?!')).toBeFalsy();
  });
  test('string with non-emoji characters', () => {
    expect(stringHasAnyEmoji('™©')).toBeFalsy();
  });
  test('has unicode emoji', () => {
    expect(stringHasAnyEmoji('🏳️‍🌈🔥🇸🇹 👩‍🔬')).toBeTruthy();
  });
  test('has custom emoji', () => {
    expect(stringHasAnyEmoji(':test: :custom:')).toBeTruthy();
  });
});
