import { useEffect } from 'react';

import classNames from 'classnames';

import { useMergedRefs } from '@/mastodon/hooks/useMergedRefs';
import { usePrevious } from '@/mastodon/hooks/usePrevious';

import { LocalCustomEmojiProvider } from '../emoji/context';
import { Menu, useMenuContext } from '../menu';
import { MenuCard } from '../menu/card';
import { Popover } from '../popover';

import { AutosuggestItem } from './items';
import classes from './styles.module.scss';
import type { Suggestion } from './types';

export interface AutosuggestMenuProps {
  suggestions: Suggestion[];
  tokenCb: () => string | null;
  onSuggestionClick: React.MouseEventHandler;
  children?: React.ReactNode;
  listRef?: React.Ref<HTMLDivElement>;
  reference?: HTMLElement | null;
  updatePopoverCb?: (update: () => void) => void;
  maxWidth?: number | string;
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
              <AutosuggestItem
                key={`${suggestion.type}:${suggestion.id}`}
                onClick={onSuggestionClick}
                suggestion={suggestion}
                data-index={index}
              />
            ))}
        </AutosuggestMenuList>
      )}
    </Menu>
  );
};

type AutosuggestMenuListProps = Omit<
  AutosuggestMenuProps,
  'onSuggestionClick'
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
  maxWidth,
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
          <MenuCard
            {...popoverChildProps}
            {...menuListProps}
            style={
              {
                '--_max-card-width':
                  typeof maxWidth === 'number' ? `${maxWidth}px` : maxWidth,
                ...popoverChildProps.style,
              } as React.CSSProperties
            }
            ref={mergedRef}
            className={classNames(maxWidth && classes.menuWidth)}
          >
            <LocalCustomEmojiProvider>{children}</LocalCustomEmojiProvider>
          </MenuCard>
        );
      }}
    </Popover>
  );
};
