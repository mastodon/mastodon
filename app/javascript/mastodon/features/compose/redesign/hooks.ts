import { useCallback, useEffect, useState } from 'react';

import { useDebouncedCallback } from 'use-debounce';

import { useResizeObserver } from '@/mastodon/hooks/useObserver';
import type { InitialStateLanguage } from '@/mastodon/initial_state';
import { languages } from '@/mastodon/initial_state';
import { useAppSelector } from '@/mastodon/store';

const emptyArray: InitialStateLanguage[] = [];

export function useLanguages() {
  return languages ?? emptyArray;
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

// Handle wrapper fade to indicate scroll.
export function useBottomFade() {
  const onWrapperScroll = useDebouncedCallback(wrapperScroll, 20, {
    leading: true,
  });
  const observer = useResizeObserver(wrapperResize);
  const onWrapperMount: React.RefCallback<HTMLElement> = useCallback(
    (ele) => {
      if (ele) {
        observer.observe(ele);
      }
    },
    [observer],
  );

  return {
    ref: onWrapperMount,
    onScroll: onWrapperScroll,
  };
}

function wrapperUpdate(ele: HTMLElement) {
  const scrollMax = ele.scrollHeight - ele.offsetHeight - 5; // 5px padding to account for sub-pixel issues
  if (scrollMax > 0 && ele.scrollTop < scrollMax) {
    ele.dataset.scrollDown = 'true';
  } else {
    delete ele.dataset.scrollDown;
  }
}

function wrapperResize(entries: ResizeObserverEntry[]) {
  for (const entry of entries) {
    if (entry.target instanceof HTMLElement) {
      wrapperUpdate(entry.target);
    }
  }
}

function wrapperScroll(event: React.UIEvent<HTMLElement>) {
  if (event.target instanceof HTMLElement) {
    wrapperUpdate(event.target);
  }
}
