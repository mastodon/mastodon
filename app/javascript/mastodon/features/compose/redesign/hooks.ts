import { useEffect, useState } from 'react';

import { languages } from '@/mastodon/initial_state';
import { useAppSelector } from '@/mastodon/store';

export function languageName(code: string) {
  return languages?.find(([lang]) => lang === code)?.[1];
}

export function useLanguageGuess() {
  const text = useAppSelector((state) =>
    (state.compose.get('text') as string).trim(),
  );
  const [guess, setGuess] = useState('');

  useEffect(() => {
    void import('../util/language_detection').then(({ debouncedGuess }) => {
      if (text.length > 20) {
        debouncedGuess(text, setGuess);
      } else {
        debouncedGuess.cancel();
      }
    });
  }, [text]);

  // Keeping track of the previous render's text length here
  // to be able to reset the guess when the text length drops
  // below the threshold needed to make a guess
  const isLongText = text.length > 20;
  const [wasLongText, setWasLongText] = useState(() => isLongText);
  if (wasLongText !== isLongText) {
    setWasLongText(isLongText);

    if (wasLongText) {
      setGuess('');
    }
  }

  return guess;
}
