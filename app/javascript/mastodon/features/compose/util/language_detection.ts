import { eld } from 'eld/extrasmall';

export function guessLanguage(text: string) {
  const guess = eld.detect(text);

  if (!guess.isReliable()) {
    return null;
  }

  return guess.language;
}
