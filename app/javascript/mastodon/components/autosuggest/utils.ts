import { WORD } from '../../utils/hashtags';

export const textAtCursorMatchesToken = (
  str: string,
  caretPosition: number,
  searchTokens: string[],
) => {
  let word: string;

  const regex = new RegExp(
    `[${searchTokens.join('')}${WORD}+-]+(\\s[${WORD}]+)?$`,
    'iu',
  );
  const left = str.slice(0, caretPosition).search(regex);
  const right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  word = word.trim();

  if (word.length < 3 || (word[0] && !searchTokens.includes(word[0]))) {
    return [null, null] as const;
  }

  if (word.length > 0) {
    return [left + 1, word] as const;
  } else {
    return [null, null] as const;
  }
};
