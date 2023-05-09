const HASHTAG_SEPARATORS = '_\\u00b7\\u200c';
const ALPHA = '\\p{L}\\p{M}';
const WORD = '\\p{L}\\p{M}\\p{N}\\p{Pc}';

const buildHashtagPatternRegex = () => {
  try {
    return new RegExp(
      `(?:^|[^\\/\\)\\w])#(([${WORD}_][${WORD}${HASHTAG_SEPARATORS}]*[${ALPHA}${HASHTAG_SEPARATORS}][${WORD}${HASHTAG_SEPARATORS}]*[${WORD}_])|([${WORD}_]*[${ALPHA}][${WORD}_]*))`,
      'iu'
    );
  } catch {
    return /(?:^|[^/)\w])#(\w*[a-zA-Z·]\w*)/i;
  }
};

const buildHashtagRegex = () => {
  try {
    return new RegExp(
      `^(([${WORD}_][${WORD}${HASHTAG_SEPARATORS}]*[${ALPHA}${HASHTAG_SEPARATORS}][${WORD}${HASHTAG_SEPARATORS}]*[${WORD}_])|([${WORD}_]*[${ALPHA}][${WORD}_]*))$`,
      'iu'
    );
  } catch {
    return /^(\w*[a-zA-Z·]\w*)$/i;
  }
};

export const HASHTAG_PATTERN_REGEX = buildHashtagPatternRegex();

export const HASHTAG_REGEX = buildHashtagRegex();
