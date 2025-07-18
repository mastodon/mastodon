import { stringHasUnicodeEmoji, stringHasUnicodeFlags } from './utils';

describe('stringHasEmoji', () => {
  test.concurrent.for([
    ['only text', false],
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
    'stringHasEmoji has emojis in "%s": %o',
    ([text, expected], { expect }) => {
      expect(stringHasUnicodeEmoji(text)).toBe(expected);
    },
  );
});

describe('stringHasFlags', () => {
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
