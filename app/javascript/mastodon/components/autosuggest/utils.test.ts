import { textAtCursorMatchesToken } from './utils';

describe('textAtCursorMatchesToken', () => {
  test.concurrent.for([
    [
      ['#hashtag', 7, ['#']],
      [1, '#hashtag'],
    ],
    [
      ['#hash tag', 8, ['#']],
      [1, '#hash tag'],
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
      [1, '#ハッシュ タグ'],
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
