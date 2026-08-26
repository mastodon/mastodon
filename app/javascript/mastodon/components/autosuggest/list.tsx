import type React from 'react';
import { useCallback, useRef } from 'react';

import { selectSuggestions } from '@/mastodon/features/compose/redesign/selectors';
import { useMergedRefs } from '@/mastodon/hooks/useMergedRefs';
import { usePrevious } from '@/mastodon/hooks/usePrevious';
import { useAppSelector } from '@/mastodon/store';
import { stringOrUndefined } from '@/mastodon/utils/strings';

import { LocalCustomEmojiProvider } from '../emoji/context';
import { getAllMenuItems, Menu, MenuItem, useMenuContext } from '../menu';
import { MenuCard } from '../menu/card';
import { Popover } from '../popover';

import { AutosuggestItem } from './items';
import type { Suggestion } from './types';
import { textAtCursorMatchesToken } from './utils';

type AutosuggestSourceElements = HTMLInputElement | HTMLTextAreaElement;

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

export type OnSuggestionSelect = (
  start: number,
  token: string,
  suggestion: Suggestion,
) => void;

interface AutosuggestMenuProps {
  suggestions: Suggestion[];
  onSuggestionClick: React.MouseEventHandler;
  listRef?: React.Ref<HTMLDivElement>;
  reference?: HTMLElement | null;
  updatePopoverCb?: (update: () => void) => void;
}

export const AutosuggestMenu: React.FC<AutosuggestMenuProps> = ({
  suggestions,
  onSuggestionClick,
  ...menuProps
}) => {
  return (
    <Menu noFocus>
      {suggestions.length > 0 && (
        <AutosuggestMenuList {...menuProps}>
          {suggestions.map((suggestion, index) => (
            <MenuItem
              key={`${suggestion.type}:${suggestion.id}`}
              onClick={onSuggestionClick}
              data-index={index}
              data-type={suggestion.type}
              data-id={suggestion.id}
            >
              <AutosuggestItem suggestion={suggestion} />
            </MenuItem>
          ))}
        </AutosuggestMenuList>
      )}
    </Menu>
  );
};

type AutosuggestMenuListProps = Pick<
  AutosuggestMenuProps,
  'listRef' | 'reference' | 'updatePopoverCb'
> & {
  children: React.ReactElement[];
};

export const AutosuggestMenuList: React.FC<AutosuggestMenuListProps> = ({
  children,
  listRef,
  reference,
  updatePopoverCb,
}) => {
  const suggestions = useAppSelector(selectSuggestions);
  const token = useAppSelector((state) =>
    stringOrUndefined(state.compose.get('suggestion_token')),
  );
  const lastToken = usePrevious(token);

  const { popover, menuListProps } = useMenuContext();

  if (!popover.isMenuOpen && token !== lastToken && suggestions.length > 0) {
    popover.openMenu();
  }

  const mergedRef = useMergedRefs(menuListProps.ref, listRef);

  return (
    <Popover
      isOpen={popover.isMenuOpen}
      onClose={popover.closeMenu}
      reference={reference !== undefined ? reference : popover.reference}
      popoverElement={popover.popover}
      container={null}
      placement='bottom-start'
    >
      {({ props: popoverChildProps, update }) => {
        updatePopoverCb?.(update);
        return (
          <MenuCard {...popoverChildProps} {...menuListProps} ref={mergedRef}>
            <LocalCustomEmojiProvider>{children}</LocalCustomEmojiProvider>
          </MenuCard>
        );
      }}
    </Popover>
  );
};
