import { useCallback, useState } from 'react';

import { Article } from '@/mastodon/components/scrollable_list/components';
import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import KeyboardArrowUpIcon from '@/material-icons/400-24px/keyboard_arrow_up.svg?react';

import { Icon } from '../icon';
import type { IconProp } from '../icon';
import { ListItemButton, ListItemWrapper } from '../list_item';

export interface TruncatedListItemInfo<TListItem> {
  item: TListItem;
  index: number;
  totalListLength: number;
  isLastElement: boolean;
}

interface ToggleButtonOptions {
  title: NonNullable<React.ReactNode>;
  subtitle?: React.ReactNode;
  icon?: IconProp;
}

interface TruncatedListProps<TListItem> {
  visibleItems: TListItem[];
  truncatedItems: TListItem[];
  renderListItem: (
    itemInfo: TruncatedListItemInfo<TListItem>,
  ) => React.ReactElement;
  toggleButton: ToggleButtonOptions;
}

/**
 * Truncate the children of an `ItemList` component with this helper
 * component.
 * It handles rendering the children with correct indexes for accessibility,
 * and has a configurable toggle button.
 */
export const TruncatedListItems = <TListItem,>({
  visibleItems,
  truncatedItems,
  toggleButton,
  renderListItem,
}: TruncatedListProps<TListItem>) => {
  const [showTruncatedItems, setShowTruncatedItems] = useState(false);
  const toggleTruncatedItems = useCallback(() => {
    setShowTruncatedItems((prev) => !prev);
  }, []);

  const hasHiddenAccounts = truncatedItems.length > 0;
  // Add the toggle button's item to the list size when needed
  const initialListSize = visibleItems.length + (hasHiddenAccounts ? 1 : 0);
  const totalListLength =
    initialListSize + (showTruncatedItems ? truncatedItems.length : 0);

  return (
    <>
      {visibleItems.map((item, index) => {
        return renderListItem({
          item,
          index,
          totalListLength,
          isLastElement:
            index === visibleItems.length - 1 && !hasHiddenAccounts,
        });
      })}
      {hasHiddenAccounts && (
        <Article aria-posinset={initialListSize} aria-setsize={totalListLength}>
          <ListItemWrapper
            icon={
              toggleButton.icon && (
                <Icon id='toggle-icon' icon={toggleButton.icon} />
              )
            }
            iconEnd={
              <Icon
                id='open-status'
                icon={
                  showTruncatedItems
                    ? KeyboardArrowUpIcon
                    : KeyboardArrowDownIcon
                }
              />
            }
          >
            <ListItemButton
              aria-expanded={showTruncatedItems}
              onClick={toggleTruncatedItems}
              subtitle={toggleButton.subtitle}
            >
              {toggleButton.title}
            </ListItemButton>
          </ListItemWrapper>
        </Article>
      )}
      {showTruncatedItems &&
        truncatedItems.map((item, index) => {
          return renderListItem({
            item,
            index: initialListSize + index + 1,
            totalListLength,
            isLastElement: index === truncatedItems.length - 1,
          });
        })}
    </>
  );
};
