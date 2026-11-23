import { eld } from 'eld/extrasmall';
import { debounce } from 'lodash';

import { replaceMentions, replaceUrls } from './url_regex';

export function guessLanguage(text: string, validLanguages?: string[]) {
  text = replaceUrls(
    replaceMentions(text, () => ''),
    '',
  );

  if (text.length <= 20) {
    return '';
  }

  const guess = eld.detect(text);

  if (!guess.isReliable()) {
    return '';
  }

  const lang = guess.language;
  if (validLanguages && !validLanguages.includes(lang)) {
    return '';
  }

  return lang;
}

export const debouncedGuess = debounce(
  (text: string, setGuess: (text: string) => void) => {
    setGuess(guessLanguage(text));
  },
  500,
  { maxWait: 1500, leading: true, trailing: true },
);
