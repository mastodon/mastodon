import { textAtCursorMatchesToken } from './utils';

describe('textAtCursorMatchesToken', () => {
  test.concurrent.for([
    [
      ['#hashtag', 7, ['#']],
      [1, '#hashtag'],
    ],
    [
      ['@alice', 6, ['@']],
      [1, '@alice'],
    ],
    [
      ['＠alice', 6, ['＠']],
      [1, '＠alice'],
    ],
    [
      ['#hash tag', 8, ['#']],
      [null, null],
    ],
    [
      [':+1', 2, [':']],
      [1, ':+1'],
    ],
    [
      [':-1', 2, [':']],
      [1, ':-1'],
    ],
    [
      ['#ハッシュタグ', 6, ['#']],
      [1, '#ハッシュタグ'],
    ],
    [
      ['#ハッシュ タグ', 7, ['#']],
      [null, null],
    ],
    [
      ['@alice reply', 12, ['@']],
      [null, null],
    ],
    [
      ['@alice 这是我输入的回复内容', 17, ['@']],
      [null, null],
    ],
    [
      ['@alice これは本文', 12, ['@']],
      [null, null],
    ],
    [
      ['@alice 이것은답변입니다', 15, ['@']],
      [null, null],
    ],
    [
      ['@alice　これは本文', 12, ['@']],
      [null, null],
    ],
  ] as const)(
    'textAtCursorMatchesToken(%s) is %o',
    ([input, expected], { expect }) => {
      expect(
        textAtCursorMatchesToken(input[0], input[1], Array.from(input[2])),
      ).toStrictEqual(expected);
    },
  );
});
