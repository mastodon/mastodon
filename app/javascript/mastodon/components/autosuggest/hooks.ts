import { useCallback, useRef } from 'react';

import { getAllMenuItems } from '../menu';

import type { AutosuggestSourceElements, Suggestion } from './types';
import { textAtCursorMatchesToken } from './utils';

export type OnSuggestionSelect = (
  start: number,
  token: string,
  suggestion: Suggestion,
) => void;

interface UseAutosuggestMenuOptions {
  suggestions: Suggestion[];
  onSelect: OnSuggestionSelect;
  onFetch?: (token: string) => void;
  onClear?: () => void;
}

export function useAutosuggestMenu({
  suggestions,
  onSelect,
  onFetch,
  onClear,
}: UseAutosuggestMenuOptions) {
  const lastTokenRef = useRef<string | null>(null); // The last suggestion token encountered.
  const tokenStartRef = useRef(0); // Character location of the token start.
  const listRef = useRef<HTMLDivElement>(null);

  const textChange: React.ChangeEventHandler<AutosuggestSourceElements> =
    useCallback(
      (event) => {
        // Detect a token, and if so fetch suggestions, or dismiss them if not.
        const [tokenStart, token] = textAtCursorMatchesToken(
          event.target.value,
          event.target.selectionStart ?? 0,
          ['@', '＠', ':', '#', '＃'],
        );

        if (token !== null && lastTokenRef.current !== token) {
          tokenStartRef.current = tokenStart;
          lastTokenRef.current = token;
          onFetch?.(token);
        } else if (token === null) {
          lastTokenRef.current = null;
          onClear?.();
        }
      },
      [onClear, onFetch],
    );

  const focus = useCallback(
    (event: React.SyntheticEvent) => {
      if (suggestions.length > 0 && listRef.current) {
        event.preventDefault();
        (getAllMenuItems(listRef.current).at(0) ?? listRef.current).focus();
      }
    },
    [suggestions.length],
  );

  const getToken = useCallback(
    () => ({
      token: lastTokenRef.current,
      startPosition: tokenStartRef.current,
    }),
    [],
  );

  const onSuggestionClick: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(
      (event) => {
        const { id, index, type } = event.currentTarget.dataset;
        const suggestion = suggestions.find((suggestion, i) =>
          suggestion.type === type && suggestion.id
            ? suggestion.id === id
            : index && Number.parseInt(index) === i,
        );
        if (!suggestion || !lastTokenRef.current) {
          return;
        }

        onSelect(tokenStartRef.current, lastTokenRef.current, suggestion);
      },
      [onSelect, suggestions],
    );

  return {
    // Used by the parent.
    textChange,
    focus,
    getToken,

    // For the component below.
    suggestions,
    onSuggestionClick,
    listRef,
  };
}
