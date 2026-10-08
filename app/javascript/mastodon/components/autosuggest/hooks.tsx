import { useCallback, useRef, useState } from 'react';

import classNames from 'classnames';

import { useThrottledCallback } from 'use-debounce';

import { normalizeKey } from '../hotkeys/utils';
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
  sourceRef: Source;
  onSelect: OnSuggestionSelect;
  onFetch?: (token: string) => void;
  onClear?: () => void;
}

type SourceProps = React.DetailedHTMLProps<
  React.HTMLAttributes<AutosuggestSourceElements>,
  AutosuggestSourceElements
>;

export function useAutosuggestMenu({
  suggestions,
  sourceRef,
  onSelect,
  onFetch,
  onClear,
}: UseAutosuggestMenuOptions) {
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

  const onSourceKeyDown: React.KeyboardEventHandler<AutosuggestSourceElements> =
    useCallback(
      (event) => {
        // Check if this composing: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/isComposing
        if (event.nativeEvent.isComposing) {
          return;
        }

        // Exit if the source is disabled.
        if (sourceToElement(sourceRef)?.disabled) {
          return;
        }

        const key = normalizeKey(event.key);
        if (key === 'escape') {
          event.preventDefault();
          // Dismiss the suggestions if we're displaying any.
          if (suggestions.length > 0) {
            onClear?.();
          } else {
            // Otherwise lose focus on the textarea.
            event.currentTarget.blur();
          }
        } else if (
          (key === 'tab' || key === 'enter') &&
          suggestions.length > 0
        ) {
          const startPosition = tokenStartRef.current;
          const token = lastTokenRef.current;
          const firstSuggestion = suggestions.at(0);

          // If we have a suggestion and token info,
          // don't move focus and instead select the first suggestion.
          if (token && firstSuggestion) {
            event.preventDefault();
            onSelect(startPosition, token, firstSuggestion);
          }
        } else if (
          key === 'down' &&
          suggestions.length > 0 &&
          listRef.current
        ) {
          event.preventDefault();
          // Focus the first item
          (getAllMenuItems(listRef.current).at(0) ?? listRef.current).focus();
        } else if (key === 'up' && suggestions.length > 0 && listRef.current) {
          event.preventDefault();
          // Focus the last item
          (getAllMenuItems(listRef.current).at(-1) ?? listRef.current).focus();
        }
      },
      [onClear, onSelect, sourceRef, suggestions],
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
      source: sourceToElement(sourceRef),
      listRef,
      tokenCb,
    } satisfies AutosuggestMenuProps,

    sourceProps: {
      'aria-autocomplete': 'list',
      'aria-expanded': suggestions.length > 0,
      'aria-haspopup': 'listbox',
      onKeyDown: onSourceKeyDown,
    } satisfies SourceProps,
  };
}

interface UseAutosuggestFloatingMenuOptions extends UseAutosuggestMenuOptions {
  text?: string;
  className?: string;
}

export function useAutosuggestFloatingMenu({
  text,
  className,
  ...suggestOptions
}: UseAutosuggestFloatingMenuOptions) {
  const [mirrorElement, setMirrorElement] = useState<HTMLElement | null>(null); // Reference to the mirror element.
  const [selectedText, setSelectedText] = useState(text ?? ''); // The actual selected text inside the mirror.
  const updatePopover = useRef<() => void>(null); // Reference to the popover update callback.

  const { getToken, ...autosuggestProps } = useAutosuggestMenu(suggestOptions);

  const source = autosuggestProps.suggestProps.source;

  const { onClear } = suggestOptions;

  // Update the popover on scroll or select.
  const onUpdate = useCallback(() => {
    // Call the popover update callback. This enables the popover to adjust position with scroll.
    updatePopover.current?.();

    if (source && mirrorElement) {
      // Set top to scroll offset so the mirror matches the current line location.
      const lineOffset =
        mirrorElement.scrollHeight - mirrorElement.clientHeight;
      mirrorElement.style.setProperty(
        'top',
        `${lineOffset - source.scrollTop}px`,
      );

      // Get the wrapper and mirror element bounds to check if the new location is out of sight...
      const wrapper = mirrorElement.parentElement?.getBoundingClientRect();
      const { bottom, top } = mirrorElement.getBoundingClientRect();
      if (wrapper && (bottom <= wrapper.top || top >= wrapper.bottom)) {
        // And clear the results if so.
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
    updatePopover.current = update;
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
    onUpdate,
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
