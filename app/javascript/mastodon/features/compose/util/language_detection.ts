import { eld } from 'eld/extrasmall';

import { languages } from '@/mastodon/initial_state';

export function guessLanguage(text: string) {
  const guess = eld.detect(text);
  if (languages) {
    eld.setLanguageSubset(languages.map(([code]) => code));
  }

  if (!guess.isReliable()) {
    return null;
  }

  return guess.language;
}
