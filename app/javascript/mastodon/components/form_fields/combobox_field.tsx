import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef, useCallback, useId, useRef, useState } from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import KeyboardArrowUpIcon from '@/material-icons/400-24px/keyboard_arrow_up.svg?react';
import { matchWidth } from 'mastodon/components/dropdown/utils';
import { IconButton } from 'mastodon/components/icon_button';
import { useOnClickOutside } from 'mastodon/hooks/useOnClickOutside';

import classes from './combobox.module.scss';
import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import { TextInput } from './text_input_field';

interface ComboboxItem {
  id: string;
}

export interface ComboboxItemState {
  isSelected: boolean;
  isDisabled: boolean;
}

interface ComboboxProps<
  T extends ComboboxItem,
> extends ComponentPropsWithoutRef<'input'> {
  value: string;
  onChange: React.ChangeEventHandler<HTMLInputElement>;
  isLoading?: boolean;
  items: T[];
  getItemId: (item: T) => string;
  getIsItemSelected?: (item: T) => boolean;
  getIsItemDisabled?: (item: T) => boolean;
  renderItem: (item: T, state: ComboboxItemState) => React.ReactElement;
  onSelectItem: (item: T) => void;
}

interface Props<T extends ComboboxItem>
  extends ComboboxProps<T>, CommonFieldWrapperProps {}

/**
 * The combobox field allows users to select one or multiple items
 * from a large list of options by searching or filtering.
 */

export const ComboboxFieldWithRef = <T extends ComboboxItem>(
  { id, label, hint, hasError, required, ...otherProps }: Props<T>,
  ref: React.ForwardedRef<HTMLInputElement>,
) => (
  <FormFieldWrapper
    label={label}
    hint={hint}
    required={required}
    hasError={hasError}
    inputId={id}
  >
    {(inputProps) => <Combobox {...otherProps} {...inputProps} ref={ref} />}
  </FormFieldWrapper>
);

// Using a type assertion to maintain the full type signature of ComboboxWithRef
// (including its generic type) after wrapping it with `forwardRef`.
export const ComboboxField = forwardRef(ComboboxFieldWithRef) as {
  <T extends ComboboxItem>(
    props: Props<T> & { ref?: React.ForwardedRef<HTMLInputElement> },
  ): ReturnType<typeof ComboboxFieldWithRef>;
  displayName: string;
};

ComboboxField.displayName = 'ComboboxField';

const ComboboxWithRef = <T extends ComboboxItem>(
  {
    value,
    isLoading = false,
    items,
    getItemId,
    getIsItemDisabled,
    getIsItemSelected,
    disabled,
    renderItem,
    onSelectItem,
    onChange,
    onKeyDown,
    className,
    ...otherProps
  }: ComboboxProps<T>,
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

  const statusMessage = useGetA11yStatusMessage({
    value,
    isLoading,
    itemCount: items.length,
  });
  const showStatusMessageInMenu =
    !!statusMessage && value.length > 0 && items.length === 0;
  const hasMenuContent =
    !disabled && (items.length > 0 || showStatusMessageInMenu);
  const isMenuOpen = shouldMenuOpen && hasMenuContent;

  const openMenu = useCallback(() => {
    setShouldMenuOpen(true);
    inputRef.current?.focus();
  }, []);

  const closeMenu = useCallback(() => {
    setShouldMenuOpen(false);
  }, []);

  const resetHighlight = useCallback(() => {
    const firstItem = items[0];
    const firstItemId = firstItem ? getItemId(firstItem) : null;
    setHighlightedItemId(firstItemId);
  }, [getItemId, items]);

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
      const item = items.find((item) => item.id === itemId);
      if (item) {
        const isDisabled = getIsItemDisabled?.(item) ?? false;
        if (!isDisabled) {
          onSelectItem(item);
        }
      }
      inputRef.current?.focus();
    },
    [getIsItemDisabled, items, onSelectItem],
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
      if (items.length === 0) {
        return;
      }
      const highlightedItemIndex = items.findIndex(
        (item) => getItemId(item) === highlightedItemId,
      );
      if (highlightedItemIndex === -1) {
        // If no item is highlighted yet, highlight the first or last
        if (direction > 0) {
          const firstItem = items.at(0);
          highlightItem(firstItem ? getItemId(firstItem) : null);
        } else {
          const lastItem = items.at(-1);
          highlightItem(lastItem ? getItemId(lastItem) : null);
        }
      } else {
        // If there is a highlighted item, select the next or previous item
        // and wrap around at the start or end:
        let newIndex = highlightedItemIndex + direction;
        if (newIndex >= items.length) {
          newIndex = 0;
        } else if (newIndex < 0) {
          newIndex = items.length - 1;
        }

        const newHighlightedItem = items[newIndex];
        highlightItem(
          newHighlightedItem ? getItemId(newHighlightedItem) : null,
        );
      }
    },
    [getItemId, highlightItem, highlightedItemId, items],
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
            {showStatusMessageInMenu ? (
              <span className={classes.emptyMessage}>{statusMessage}</span>
            ) : (
              <ul role='listbox' id={listId} tabIndex={-1}>
                {items.map((item) => {
                  const id = getItemId(item);
                  const isDisabled = getIsItemDisabled?.(item);
                  const isHighlighted = id === highlightedItemId;
                  // If `getIsItemSelected` is defined, we assume 'multi-select'
                  // behaviour and don't set `aria-selected` based on highlight,
                  // but based on selected item state.
                  const isSelected = getIsItemSelected
                    ? getIsItemSelected(item)
                    : isHighlighted;
                  return (
                    // eslint-disable-next-line jsx-a11y/click-events-have-key-events
                    <li
                      key={id}
                      role='option'
                      className={classes.menuItem}
                      data-highlighted={isHighlighted}
                      aria-selected={isSelected}
                      aria-disabled={isDisabled}
                      data-item-id={id}
                      onMouseEnter={handleItemMouseEnter}
                      onClick={handleSelectItem}
                    >
                      {renderItem(item, {
                        isSelected,
                        isDisabled: isDisabled ?? false,
                      })}
                    </li>
                  );
                })}
              </ul>
            )}
          </div>
        )}
      </Overlay>
    </div>
  );
};

// Using a type assertion to maintain the full type signature of ComboboxWithRef
// (including its generic type) after wrapping it with `forwardRef`.
export const Combobox = forwardRef(ComboboxWithRef) as {
  <T extends ComboboxItem>(
    props: ComboboxProps<T> & { ref?: React.ForwardedRef<HTMLInputElement> },
  ): ReturnType<typeof ComboboxWithRef>;
  displayName: string;
};

Combobox.displayName = 'Combobox';

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
