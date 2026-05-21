import {
  createContext,
  forwardRef,
  useCallback,
  useContext,
  useId,
  useMemo,
  useRef,
  useState,
} from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import KeyboardArrowUpIcon from '@/material-icons/400-24px/keyboard_arrow_up.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import { matchWidth } from 'mastodon/components/dropdown/utils';
import { IconButton } from 'mastodon/components/icon_button';
import { useOnClickOutside } from 'mastodon/hooks/useOnClickOutside';

import { LoadingIndicator } from '../loading_indicator';

import classes from './combobox.module.scss';
import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import { TextInput } from './text_input_field';
import type { TextInputProps } from './text_input_field';

interface ComboboxItem {
  id: string;
}

export interface ComboboxItemState {
  isSelected: boolean;
  isDisabled: boolean;
}

interface ComboboxProps<
  Item extends ComboboxItem,
  GroupKey extends string,
> extends Omit<TextInputProps, 'icon'> {
  /**
   * The value of the combobox's text input
   */
  value: string;
  /**
   * Change handler for the text input field
   */
  onChange: React.ChangeEventHandler<HTMLInputElement>;
  /**
   * Set this to true when the list of options is dynamic and currently loading.
   * Causes a loading indicator to be displayed inside of the dropdown menu.
   */
  isLoading?: boolean;
  /**
   * The set of options/suggestions that should be rendered in the dropdown menu,
   * optionally separated into groups by providing an object
   */
  items: Item[] | Partial<Record<GroupKey, Item[]>>;
  /**
   * A function that must return a unique id for each option passed via `items`
   */
  getItemId?: (item: Item) => string;
  /**
   * Providing this function turns the combobox into a multi-select box that assumes
   * multiple options to be selectable. Single-selection is handled automatically.
   */
  getIsItemSelected?: (item: Item) => boolean;
  /**
   * Use this function to mark items as disabled, if needed
   */
  getIsItemDisabled?: (item: Item) => boolean;
  /**
   * Customise the rendering of each option.
   * The rendered content must not contain other interactive content!
   */
  renderItem: (
    item: Item,
    state: ComboboxItemState,
  ) => React.ReactElement | string;
  /**
   * Customise the rendering of group titles.
   * The `titleId` must be attached to the element that provides the
   * accessible name for the group.
   * Return `null` to omit rendering the group title.
   */
  renderGroupTitle?: (
    groupKey: GroupKey,
    titleId: string,
  ) => React.ReactElement | null;
  /**
   * The main selection handler, called when an option is selected or deselected.
   */
  onSelectItem: (item: Item) => void;
  /**
   * Icon to be displayed in the text input
   */
  icon?: TextInputProps['icon'] | null;
  /**
   * Set to false to keep the menu open when an item is selected
   */
  closeOnSelect?: boolean;
  /**
   * Prevent the menu from opening, e.g. to prevent the empty state from showing
   */
  suppressMenu?: boolean;
}

interface Props<Item extends ComboboxItem, GroupKey extends string>
  extends ComboboxProps<Item, GroupKey>, CommonFieldWrapperProps {}

interface ComboboxItemPropsContext {
  role: 'option';
  'data-highlighted': boolean;
  'aria-selected': boolean;
  'aria-disabled': boolean;
  'data-item-id': string;
  onMouseEnter: React.MouseEventHandler<HTMLLIElement>;
  onClick: React.MouseEventHandler<HTMLLIElement>;
}

const ComboboxItemPropsContext = createContext<ComboboxItemPropsContext | null>(
  null,
);

export function useComboboxItemProps() {
  const context = useContext(ComboboxItemPropsContext);

  if (context === null) {
    throw new Error(
      'useComboboxItemProps must be used within a Combobox component',
    );
  }

  return context;
}

export const ComboboxMenuItem: React.FC<{
  className?: string;
  children: React.ReactNode;
}> = ({ className, children }) => {
  const props = useComboboxItemProps();
  return (
    <li className={classNames(className, classes.menuItem)} {...props}>
      {children}
    </li>
  );
};

export const ComboboxMenuGroupTitle: React.FC<
  React.ComponentPropsWithoutRef<'li'>
> = ({ className, children, ...otherProps }) => {
  return (
    <li
      {...otherProps}
      role='presentation'
      className={classNames(className, classes.groupTitle)}
    >
      {children}
    </li>
  );
};

/**
 * The combobox field allows users to select one or more items
 * by searching or filtering a large or dynamic list of options.
 *
 * It is an implementation of the [APG Combobox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/),
 * with inspiration taken from Sarah Higley's extensive combobox
 * [research & implementations](https://sarahmhigley.com/writing/select-your-poison/).
 */

export const ComboboxFieldWithRef = <
  Item extends ComboboxItem,
  GroupKey extends string,
>(
  { id, label, hint, status, required, ...otherProps }: Props<Item, GroupKey>,
  ref: React.ForwardedRef<HTMLInputElement>,
) => (
  <FormFieldWrapper
    label={label}
    hint={hint}
    required={required}
    status={status}
    inputId={id}
  >
    {(inputProps) => <Combobox {...otherProps} {...inputProps} ref={ref} />}
  </FormFieldWrapper>
);

// Using a type assertion to maintain the full type signature of ComboboxWithRef
// (including its generic type) after wrapping it with `forwardRef`.
export const ComboboxField = forwardRef(ComboboxFieldWithRef) as {
  <Item extends ComboboxItem, GroupKey extends string>(
    props: Props<Item, GroupKey> & {
      ref?: React.ForwardedRef<HTMLInputElement>;
    },
  ): ReturnType<typeof ComboboxFieldWithRef>;
  displayName: string;
};

ComboboxField.displayName = 'ComboboxField';

const ComboboxWithRef = <Item extends ComboboxItem, GroupKey extends string>(
  {
    value,
    isLoading = false,
    items,
    getItemId = (item) => item.id,
    getIsItemDisabled,
    getIsItemSelected,
    disabled,
    renderGroupTitle,
    renderItem,
    onSelectItem,
    onChange,
    onKeyDown,
    closeOnSelect = true,
    suppressMenu = false,
    icon = SearchIcon,
    className,
    ...otherProps
  }: ComboboxProps<Item, GroupKey>,
  ref: React.ForwardedRef<HTMLInputElement>,
) => {
  const intl = useIntl();
  const wrapperRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement | null>();
  const popoverRef = useRef<HTMLDivElement>(null);

  const [highlightedItemId, setHighlightedItemId] = useState<string | null>(
    null,
  );
  const [shouldMenuOpen, setShouldMenuOpen] = useState(false);

  const hasGroups = !Array.isArray(items);
  const flatItems = useMemo(
    () =>
      hasGroups
        ? (Object.values(items)
            .flat()
            .filter((i) => !!i) as Item[])
        : items,
    [hasGroups, items],
  );

  const statusMessage = useGetA11yStatusMessage({
    value,
    isLoading,
    itemCount: flatItems.length,
  });
  const showStatusMessageInMenu =
    !!statusMessage && value.length > 0 && flatItems.length === 0;
  const hasMenuContent =
    !disabled &&
    !suppressMenu &&
    (flatItems.length > 0 || showStatusMessageInMenu);
  const isMenuOpen = shouldMenuOpen && hasMenuContent;

  const openMenu = useCallback(() => {
    setShouldMenuOpen(true);
    inputRef.current?.focus();
  }, []);

  const closeMenu = useCallback(() => {
    setShouldMenuOpen(false);
  }, []);

  const resetHighlight = useCallback(() => {
    const firstItem = flatItems[0];
    const firstItemId = firstItem ? getItemId(firstItem) : null;
    setHighlightedItemId(firstItemId);
  }, [getItemId, flatItems]);

  const highlightItem = useCallback((id: string | null) => {
    setHighlightedItemId(id);
    if (id) {
      const itemElement = popoverRef.current?.querySelector<HTMLLIElement>(
        `[data-item-id='${id}']`,
      );
      if (itemElement && popoverRef.current) {
        scrollItemIntoView(itemElement, popoverRef.current);
      }
    }
  }, []);

  const handleInputChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      onChange(e);
      resetHighlight();
      setShouldMenuOpen(!!e.target.value);
    },
    [onChange, resetHighlight],
  );

  const handleItemMouseEnter = useCallback(
    (e: React.MouseEvent<HTMLLIElement>) => {
      const { itemId } = e.currentTarget.dataset;
      if (itemId) {
        highlightItem(itemId);
      }
    },
    [highlightItem],
  );

  const selectItem = useCallback(
    (itemId: string | null) => {
      const item = flatItems.find((item) => item.id === itemId);
      if (item) {
        const isDisabled = getIsItemDisabled?.(item) ?? false;
        if (!isDisabled) {
          onSelectItem(item);

          if (closeOnSelect) {
            closeMenu();
          }
        }
      }
      inputRef.current?.focus();
    },
    [closeMenu, closeOnSelect, getIsItemDisabled, flatItems, onSelectItem],
  );

  const handleSelectItem = useCallback(
    (e: React.MouseEvent<HTMLLIElement>) => {
      const { itemId } = e.currentTarget.dataset;
      selectItem(itemId ?? null);
    },
    [selectItem],
  );

  const selectHighlightedItem = useCallback(() => {
    selectItem(highlightedItemId);
  }, [highlightedItemId, selectItem]);

  const moveHighlight = useCallback(
    (direction: number) => {
      if (flatItems.length === 0) {
        return;
      }
      const highlightedItemIndex = flatItems.findIndex(
        (item) => getItemId(item) === highlightedItemId,
      );
      if (highlightedItemIndex === -1) {
        // If no item is highlighted yet, highlight the first or last
        if (direction > 0) {
          const firstItem = flatItems.at(0);
          highlightItem(firstItem ? getItemId(firstItem) : null);
        } else {
          const lastItem = flatItems.at(-1);
          highlightItem(lastItem ? getItemId(lastItem) : null);
        }
      } else {
        // If there is a highlighted item, select the next or previous item
        // and wrap around at the start or end:
        let newIndex = highlightedItemIndex + direction;
        if (newIndex >= flatItems.length) {
          newIndex = 0;
        } else if (newIndex < 0) {
          newIndex = flatItems.length - 1;
        }

        const newHighlightedItem = flatItems[newIndex];
        highlightItem(
          newHighlightedItem ? getItemId(newHighlightedItem) : null,
        );
      }
    },
    [getItemId, highlightItem, highlightedItemId, flatItems],
  );

  useOnClickOutside(wrapperRef, closeMenu);

  const handleInputKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      onKeyDown?.(e);

      if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (isMenuOpen) {
          moveHighlight(-1);
        } else {
          openMenu();
        }
      }
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (isMenuOpen) {
          moveHighlight(1);
        } else {
          openMenu();
        }
      }
      if (e.key === 'Tab') {
        if (isMenuOpen) {
          selectHighlightedItem();
          closeMenu();
        }
      }
      if (e.key === 'Enter') {
        if (isMenuOpen) {
          e.preventDefault();
          selectHighlightedItem();
        }
      }
      if (e.key === 'Escape') {
        if (isMenuOpen) {
          e.preventDefault();
          closeMenu();
        }
      }
    },
    [
      closeMenu,
      isMenuOpen,
      moveHighlight,
      onKeyDown,
      openMenu,
      selectHighlightedItem,
    ],
  );

  const renderItems = (items: Item[]) =>
    items.map((item) => {
      const id = getItemId(item);
      const isDisabled = getIsItemDisabled?.(item) ?? false;
      const isHighlighted = id === highlightedItemId;
      // If `getIsItemSelected` is defined, we assume 'multi-select'
      // behaviour and don't set `aria-selected` based on highlight,
      // but based on selected item state.
      const isSelected = getIsItemSelected
        ? getIsItemSelected(item)
        : isHighlighted;
      return (
        <ComboboxItemPropsContext.Provider
          key={id}
          value={{
            role: 'option',
            'data-highlighted': isHighlighted,
            'aria-selected': isSelected,
            'aria-disabled': isDisabled,
            'data-item-id': id,
            onMouseEnter: handleItemMouseEnter,
            onClick: handleSelectItem,
          }}
        >
          {renderItem(item, {
            isSelected,
            isDisabled,
          })}
        </ComboboxItemPropsContext.Provider>
      );
    });

  const mergeRefs = useCallback(
    (element: HTMLInputElement | null) => {
      inputRef.current = element;
      if (typeof ref === 'function') {
        ref(element);
      } else if (ref) {
        ref.current = element;
      }
    },
    [ref],
  );

  const id = useId();
  const listId = `${id}-list`;

  return (
    <div className={classes.wrapper} ref={wrapperRef}>
      <TextInput
        role='combobox'
        {...otherProps}
        disabled={disabled}
        aria-controls={listId}
        aria-expanded={isMenuOpen ? 'true' : 'false'}
        aria-haspopup='listbox'
        aria-activedescendant={
          isMenuOpen && highlightedItemId ? highlightedItemId : undefined
        }
        aria-autocomplete='list'
        autoComplete='off'
        spellCheck='false'
        value={value}
        onChange={handleInputChange}
        onKeyDown={handleInputKeyDown}
        icon={icon ?? undefined}
        className={classNames(classes.input, className)}
        ref={mergeRefs}
      />
      {hasMenuContent && (
        <IconButton
          title={
            isMenuOpen
              ? intl.formatMessage({
                  id: 'combobox.close_results',
                  defaultMessage: 'Close results',
                })
              : intl.formatMessage({
                  id: 'combobox.open_results',
                  defaultMessage: 'Open results',
                })
          }
          className={classes.menuButton}
          icon='results'
          iconComponent={
            isMenuOpen ? KeyboardArrowUpIcon : KeyboardArrowDownIcon
          }
          onClick={isMenuOpen ? closeMenu : openMenu}
        />
      )}
      <span role='status' aria-live='polite' className='sr-only'>
        {isMenuOpen && statusMessage}
      </span>
      <Overlay
        show={isMenuOpen}
        offset={[0, 1]}
        placement='bottom-start'
        onHide={closeMenu}
        ref={popoverRef}
        target={inputRef as React.RefObject<HTMLInputElement>}
        container={wrapperRef}
        popperConfig={{
          modifiers: [matchWidth],
        }}
      >
        {({ props, placement }) => (
          <div {...props} className={classNames(classes.popover, placement)}>
            <StatusMessageWrapper
              showStatus={showStatusMessageInMenu}
              isLoading={isLoading}
              status={statusMessage}
            >
              {hasGroups ? (
                <div role='listbox' id={listId} tabIndex={-1}>
                  {(Object.keys(items) as GroupKey[]).map((groupKey) => {
                    const groupItems = items[groupKey];
                    const groupTitleId = `${listId}-group-${groupKey}`;
                    const customGroupTitle = renderGroupTitle?.(
                      groupKey,
                      groupTitleId,
                    );
                    const hasTitle = customGroupTitle !== null;

                    if (!groupItems?.length) return null;

                    return (
                      <ul
                        key={groupKey}
                        role='group'
                        aria-labelledby={hasTitle ? groupTitleId : undefined}
                      >
                        {hasTitle &&
                          (customGroupTitle ?? (
                            <ComboboxMenuGroupTitle id={groupTitleId}>
                              {groupKey}
                            </ComboboxMenuGroupTitle>
                          ))}
                        {renderItems(groupItems)}
                      </ul>
                    );
                  })}
                </div>
              ) : (
                <ul role='listbox' id={listId} tabIndex={-1}>
                  {renderItems(items)}
                </ul>
              )}
            </StatusMessageWrapper>
          </div>
        )}
      </Overlay>
    </div>
  );
};

// Using a type assertion to maintain the full type signature of ComboboxWithRef
// (including its generic type) after wrapping it with `forwardRef`.
export const Combobox = forwardRef(ComboboxWithRef) as {
  <Item extends ComboboxItem, GroupKey extends string>(
    props: ComboboxProps<Item, GroupKey> & {
      ref?: React.ForwardedRef<HTMLInputElement>;
    },
  ): ReturnType<typeof ComboboxWithRef>;
  displayName: string;
};

Combobox.displayName = 'Combobox';

const StatusMessageWrapper: React.FC<{
  showStatus: boolean;
  status: string;
  isLoading: boolean;
  children: React.ReactNode;
}> = ({ showStatus, status, isLoading, children }) => {
  if (showStatus) {
    return (
      <span className={classes.emptyMessage}>
        {isLoading && (
          <span className={classes.loadingIndicator}>
            <LoadingIndicator role='none' />
          </span>
        )}
        {status}
      </span>
    );
  }

  return children;
};

function useGetA11yStatusMessage({
  itemCount,
  value,
  isLoading,
}: {
  itemCount: number;
  value: string;
  isLoading: boolean;
}): string {
  const intl = useIntl();

  if (isLoading) {
    return intl.formatMessage({
      id: 'combobox.loading',
      defaultMessage: 'Loading',
    });
  }

  if (value.length && !itemCount) {
    return intl.formatMessage({
      id: 'combobox.no_results_found',
      defaultMessage: 'No results for this search',
    });
  }

  if (itemCount > 0) {
    return intl.formatMessage(
      {
        id: 'combobox.results_available',
        defaultMessage:
          '{count, plural, one {# suggestion} other {# suggestions}} available. Use up and down arrow keys to navigate. Press Enter key to select.',
      },
      {
        count: itemCount,
      },
    );
  }
  return '';
}

const SCROLL_MARGIN = 6;

function scrollItemIntoView(item: HTMLElement, scrollParent: HTMLElement) {
  const itemTopEdge = item.offsetTop;
  const itemBottomEdge = itemTopEdge + item.offsetHeight;

  // If item is above scroll area, scroll up
  if (itemTopEdge < scrollParent.scrollTop) {
    scrollParent.scrollTop = itemTopEdge - SCROLL_MARGIN;
  }
  // If item is below scroll area, scroll down
  else if (
    itemBottomEdge >
    scrollParent.scrollTop + scrollParent.offsetHeight
  ) {
    scrollParent.scrollTop =
      itemBottomEdge - scrollParent.offsetHeight + SCROLL_MARGIN;
  }
}
