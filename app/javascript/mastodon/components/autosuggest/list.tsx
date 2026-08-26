import { useEffect } from 'react';

import { useMergedRefs } from '@/mastodon/hooks/useMergedRefs';
import { usePrevious } from '@/mastodon/hooks/usePrevious';

import { LocalCustomEmojiProvider } from '../emoji/context';
import { Menu, MenuItem, useMenuContext } from '../menu';
import { MenuCard } from '../menu/card';
import { Popover } from '../popover';

import { AutosuggestItem } from './items';
import type { Suggestion } from './types';

export interface AutosuggestMenuProps {
  suggestions: Suggestion[];
  tokenCb: () => string | null;
  onSuggestionClick: React.MouseEventHandler;
  children?: React.ReactNode;
  listRef?: React.Ref<HTMLDivElement>;
  reference?: HTMLElement | null;
  updatePopoverCb?: (update: () => void) => void;
}

export const AutosuggestMenu: React.FC<AutosuggestMenuProps> = ({
  suggestions,
  onSuggestionClick,
  children,
  ...menuProps
}) => {
  return (
    <Menu noFocus>
      {suggestions.length > 0 && (
        <AutosuggestMenuList {...menuProps} suggestions={suggestions}>
          {children ??
            suggestions.map((suggestion, index) => (
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
  'listRef' | 'suggestions' | 'tokenCb' | 'reference' | 'updatePopoverCb'
> & {
  children: React.ReactNode;
};

const AutosuggestMenuList: React.FC<AutosuggestMenuListProps> = ({
  children,
  listRef,
  tokenCb,
  suggestions,
  reference,
  updatePopoverCb,
}) => {
  const token = tokenCb();
  const lastToken = usePrevious(token);

  const { popover, menuListProps } = useMenuContext();

  useEffect(() => {
    if (!popover.isMenuOpen && token !== lastToken && suggestions.length > 0) {
      popover.openMenu();
    }
  }, [lastToken, popover, suggestions.length, token]);

  const mergedRef = useMergedRefs(menuListProps.ref, listRef);

  return (
    <Popover
      isOpen={popover.isMenuOpen}
      onClose={popover.closeMenu}
      reference={reference ?? null}
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
