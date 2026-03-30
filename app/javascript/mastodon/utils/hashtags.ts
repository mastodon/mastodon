const HASHTAG_SEPARATORS = '_\\u00b7\\u200c';
const ALPHA = '\\p{L}\\p{M}';
const WORD = '\\p{L}\\p{M}\\p{N}\\p{Pc}';

const buildHashtagPatternRegex = () => {
  try {
    return new RegExp(
      `(?:^|[^\\/\\)\\w])#(([${WORD}_][${WORD}${HASHTAG_SEPARATORS}]*[${ALPHA}${HASHTAG_SEPARATORS}][${WORD}${HASHTAG_SEPARATORS}]*[${WORD}_])|([${WORD}_]*[${ALPHA}][${WORD}_]*))`,
      'iu',
    );
  } catch {
    return /(?:^|[^/)\w])#(\w*[a-zA-Z·]\w*)/i;
  }
};

const buildHashtagRegex = () => {
  try {
    return new RegExp(
      `^(([${WORD}_][${WORD}${HASHTAG_SEPARATORS}]*[${ALPHA}${HASHTAG_SEPARATORS}][${WORD}${HASHTAG_SEPARATORS}]*[${WORD}_])|([${WORD}_]*[${ALPHA}][${WORD}_]*))$`,
      'iu',
    );
  } catch {
    return /^(\w*[a-zA-Z·]\w*)$/i;
  }
};

export const HASHTAG_PATTERN_REGEX = buildHashtagPatternRegex();

export const HASHTAG_REGEX = buildHashtagRegex();

export const trimHashFromStart = (input: string) => {
  return input.startsWith('#') || input.startsWith('＃')
    ? input.slice(1)
    : input;
};

/**
 * Formats an input string as a hashtag:
 * - Prepends `#` unless present
 * - Strips spaces (except at the end, to allow typing it)
 * - Capitalises first character after stripped space
 */
export const inputToHashtag = (input: string): string => {
  if (!input) {
    return '';
  }

  const trailingSpace = /\s+$/.exec(input)?.[0] ?? '';
  const trimmedInput = input.trimEnd();
  const withoutHash = trimHashFromStart(trimmedInput);

  // Split by space, filter empty strings, and capitalise the start of each word but the first
  const words = withoutHash
    .split(/\s+/)
    .filter((word) => word.length > 0)
    .map((word, index) =>
      index === 0
        ? word
        : word.charAt(0).toUpperCase() + word.slice(1).toLowerCase(),
    );

  return `#${words.join('')}${trailingSpace}`;
};

export const hasSpecialCharacters = (input: string) => {
  // Regex matches any character NOT a letter/digit, except the #
  return /[^a-zA-Z0-9# ]/.test(input);
};
