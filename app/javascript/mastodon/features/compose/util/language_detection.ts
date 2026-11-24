import { eld } from 'eld/extrasmall';

import { replaceMentions, replaceUrls } from './url_regex';

export function guessLanguage(text: string) {
  text = replaceUrls(
    replaceMentions(text, () => ''),
    '',
  );

  const guess = eld.detect(text);

  if (!guess.isReliable()) {
    return null;
  }

  return guess.language;
}
