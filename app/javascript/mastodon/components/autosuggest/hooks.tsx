import { useCallback, useRef, useState } from 'react';

import classNames from 'classnames';

import type { Simplify } from 'type-fest';
import { useThrottledCallback } from 'use-debounce';

import { getAllMenuItems } from '../menu';

import type { AutosuggestMenuProps } from './list';
import classes from './styles.module.scss';
import type { AutosuggestSourceElements, Source, Suggestion } from './types';
import { sourceToElement, textAtCursorMatchesToken } from './utils';

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

type SourceProps = React.DetailedHTMLProps<
  React.HTMLAttributes<AutosuggestSourceElements>,
  AutosuggestSourceElements
>;

interface UseAutosuggestReturn {
  onTextChange: React.ChangeEventHandler<AutosuggestSourceElements>;
  focus: (event?: React.SyntheticEvent) => void;
  getToken: () => { token: string | null; startPosition: number };

  mirror?: React.JSX.Element;

  suggestProps: Simplify<Omit<AutosuggestMenuProps, 'children'>>;

  sourceProps: Simplify<
    Pick<SourceProps, 'onSelect' | 'onScroll' | 'aria-autocomplete'>
  >;
}

export function useAutosuggestMenu({
  suggestions,
  onSelect,
  onFetch,
  onClear,
}: UseAutosuggestMenuOptions): UseAutosuggestReturn {
  const lastTokenRef = useRef<string | null>(null); // The last suggestion token encountered.
  const tokenStartRef = useRef(0); // Character location of the token start.
  const listRef = useRef<HTMLDivElement>(null);

  const onTextChange: React.ChangeEventHandler<AutosuggestSourceElements> =
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
    (event?: React.SyntheticEvent) => {
      if (suggestions.length > 0 && listRef.current) {
        event?.preventDefault();
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
  const tokenCb = useCallback(() => lastTokenRef.current, []);

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
    onTextChange,
    focus,
    getToken,

    // For the component below.
    suggestProps: {
      suggestions,
      onSuggestionClick,
      listRef,
      tokenCb,
    } satisfies AutosuggestMenuProps,

    sourceProps: {
      'aria-autocomplete': 'list',
    } satisfies SourceProps,
  };
}

interface UseAutosuggestFloatingMenuOptions extends UseAutosuggestMenuOptions {
  text?: string;
  sourceRef: Source;
  className?: string;
}

export function useAutosuggestFloatingMenu({
  text,
  sourceRef,
  className,
  ...suggestOptions
}: UseAutosuggestFloatingMenuOptions): UseAutosuggestReturn {
  const [mirrorElement, setMirrorElement] = useState<HTMLElement | null>(null); // Reference to the mirror element.
  const [selectedText, setSelectedText] = useState(text ?? ''); // The actual selected text inside the mirror.
  const updatePopover = useRef<() => void>(null); // Reference to the popover update callback.

  const { getToken, ...autosuggestProps } = useAutosuggestMenu(suggestOptions);

  const { onClear } = suggestOptions;

  const source = sourceToElement(sourceRef);

  // Update the popover on scroll or select.
  const onUpdate = useCallback(() => {
    // Call the popover update callback. This enables the popover to adjust position with scroll.
    updatePopover.current?.();

    if (source && mirrorElement) {
      // Set top to scroll offset so bottom edge looks right.
      mirrorElement.style.setProperty('top', `${-1 * source.scrollTop}px`);

      const { height } = source.getBoundingClientRect();
      const offset = mirrorElement.offsetHeight - source.scrollTop;
      if (offset < 0 || offset > height) {
        onClear?.();
      }
    }
  }, [mirrorElement, onClear, source, updatePopover]);

  // When the caret or selection changes, update the selected text and clear the composer if it doesn't include a token.
  const onSelect: React.ReactEventHandler<AutosuggestSourceElements> =
    useCallback(
      (event) => {
        const { token, startPosition } = getToken();
        if (token === null) {
          return;
        }

        onUpdate();

        const { selectionStart: rawStart, value } = event.currentTarget;
        const selectionStart = rawStart ?? 0;
        const tokenEnd = startPosition + token.length;
        setSelectedText(value.slice(0, tokenEnd)); // Only set the text up to the selected end point.

        if (selectionStart < startPosition || selectionStart > tokenEnd) {
          onClear?.();
        }
      },
      [getToken, onClear, onUpdate],
    );

  const onScroll = useThrottledCallback(onUpdate, 0);
  const updatePopoverCb = useCallback((update: () => void) => {
    updatePopover.current = () => update;
  }, []);

  const mirror = (
    <div
      className={classNames(
        classes.mirror,
        source instanceof HTMLTextAreaElement && classes.textAreaMirror,
        className,
      )}
      ref={setMirrorElement}
    >
      {selectedText}
    </div>
  );

  return {
    mirror,
    getToken,
    ...autosuggestProps,

    sourceProps: {
      ...autosuggestProps.sourceProps,
      onScroll,
      onSelect,
    } satisfies SourceProps,

    suggestProps: {
      ...autosuggestProps.suggestProps,
      reference: mirrorElement,
      updatePopoverCb,
    } satisfies AutosuggestMenuProps,
  };
}
