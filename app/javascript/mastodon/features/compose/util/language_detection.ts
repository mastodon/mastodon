import { eld } from 'eld/extrasmall';

import { replaceMentions, replaceUrls } from './url_regex';

export function guessLanguage(text: string, validLanguages?: string[]) {
  text = replaceUrls(
    replaceMentions(text, () => ''),
    '',
  );

  const guess = eld.detect(text);

  if (!guess.isReliable()) {
    return null;
  }

  const lang = guess.language;
  if (validLanguages && !validLanguages.includes(lang)) {
    return null;
  }

  return lang;
}
