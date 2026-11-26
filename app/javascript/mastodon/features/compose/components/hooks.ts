import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import type { Map as ImmutableMap } from 'immutable';

import type { Fuzzysort } from 'fuzzysort';
import { useDebouncedCallback } from 'use-debounce';

import type { InitialStateLanguage } from '@/mastodon/initial_state';
import { languages } from '@/mastodon/initial_state';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import {
  removeHashtags,
  replaceMentions,
  replaceUrls,
} from '../util/url_regex';

export function useLanguages() {
  return languages;
}

export function languageName(code: string) {
  return languages?.find(([lang]) => lang === code)?.[1];
}

// Only extract useful text below the threshold.
const GUESS_TEXT_LENGTH = 40;
const selectTextForGuessing = createAppSelector(
  [(state) => state.compose.get('text') as string],
  (rawText) => {
    let text = replaceMentions(rawText);
    text = replaceUrls(text);
    text = removeHashtags(text);
    text = text.trim();

    if (text.length <= GUESS_TEXT_LENGTH) {
      return null;
    }
    return text;
  },
);

export function useLanguageGuess() {
  const text = useAppSelector(selectTextForGuessing);
  const [guess, setGuess] = useState('');

  const debouncedGuess = useDebouncedCallback(
    async (input: string) => {
      const { guessLanguage } = await import('../util/language_detection');

      return guessLanguage(input);
    },
    500,
    { maxWait: 1500, leading: true, trailing: true },
  );

  useEffect(() => {
    debouncedGuess.cancel();
    if (!text) {
      return;
    }
    const promise = debouncedGuess(text);

    if (!promise) {
      return;
    }

    promise
      .then((guess) => {
        // Use languageName to ensure the language code exists.
        if (guess && languageName(guess)) {
          setGuess(guess);
        } else {
          setGuess('');
        }
      })
      .catch(() => {
        setGuess('');
      });
  }, [debouncedGuess, text]);

  // Remove guess when the text is lower than the threshold.
  if (!text && guess) {
    setGuess('');
  }

  return guess;
}

const selectFrequentlyUsedLanguages = createAppSelector(
  [
    (state) =>
      state.settings.get('frequentlyUsedLanguages') as
        | ImmutableMap<string, number>
        | undefined,
  ],
  (languageCounters) =>
    !languageCounters
      ? []
      : languageCounters
          .keySeq()
          .sort(
            (a, b) =>
              (languageCounters.get(a) ?? 0) - (languageCounters.get(b) ?? 0),
          )
          .reverse()
          .toArray(),
);

export function useLanguageList() {
  const frequentlyUsed = useAppSelector(selectFrequentlyUsedLanguages);
  const currentLang = useAppSelector(
    (state) => state.compose.get('language') as string,
  );
  const guess = useLanguageGuess();

  const sortedLanguages = useMemo(() => {
    if (!languages) {
      return [];
    }
    return [...languages].sort((a, b) => {
      if (guess && a[0] === guess) {
        // Push guessed language higher than current selection
        return -1;
      } else if (guess && b[0] === guess) {
        return 1;
      } else if (a[0] === currentLang) {
        // Push current selection to the top of the list
        return -1;
      } else if (b[0] === currentLang) {
        return 1;
      } else {
        // Sort according to frequently used languages

        const indexOfA = frequentlyUsed.indexOf(a[0]);
        const indexOfB = frequentlyUsed.indexOf(b[0]);

        return (
          (indexOfA > -1 ? indexOfA : Infinity) -
          (indexOfB > -1 ? indexOfB : Infinity)
        );
      }
    });
  }, [currentLang, frequentlyUsed, guess]);

  const fuzzySortRef = useRef<Fuzzysort>(null);
  useEffect(() => {
    void import('fuzzysort').then((fuzzySort) => {
      fuzzySortRef.current = fuzzySort;
    });
  }, []);

  const [searchResults, setSearchResults] = useState<
    InitialStateLanguage[] | null
  >(null);

  const onSearch = useDebouncedCallback((search: string) => {
    if (!search || !fuzzySortRef.current) {
      setSearchResults(null);
      return;
    }
    const results = fuzzySortRef.current
      .go(search, languages ?? [], {
        keys: ['0', '1', '2'],
        limit: 5,
        threshold: -10000,
      })
      .map((result) => result.obj);
    setSearchResults(results);
  }, 10);

  const onClear = useCallback(() => {
    setSearchResults(null);
  }, []);

  return {
    onSearch,
    onClear,
    languages: searchResults ?? sortedLanguages,
  };
}
