import {
  useState,
  useEffect,
  useRef,
  useCallback,
  cloneElement,
  Children,
  useId,
} from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { Map as ImmutableMap } from 'immutable';

import type {
  OffsetValue,
  UsePopperOptions,
  Placement,
} from 'react-overlays/esm/usePopper';
import Overlay from 'react-overlays/Overlay';

import { fetchRelationships } from 'mastodon/actions/accounts';
import {
  openDropdownMenu,
  closeDropdownMenu,
} from 'mastodon/actions/dropdown_menu';
import { openModal, closeModal } from 'mastodon/actions/modal';
import { fetchStatus } from 'mastodon/actions/statuses';
import { CircularProgress } from 'mastodon/components/circular_progress';
import { isUserTouching } from 'mastodon/is_mobile';
import {
  isMenuItem,
  isActionItem,
  isExternalLinkItem,
} from 'mastodon/models/dropdown_menu';
import type { MenuItem } from 'mastodon/models/dropdown_menu';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { Icon } from './icon';
import type { IconProp } from './icon';
import { IconButton } from './icon_button';

let id = 0;

export type RenderItemFn<Item = MenuItem> = (
  item: Item,
  index: number,
  onClick: React.MouseEventHandler,
) => React.ReactNode;

type ItemClickFn<Item = MenuItem> = (item: Item, index: number) => void;

type RenderHeaderFn<Item = MenuItem> = (items: Item[]) => React.ReactNode;

interface DropdownMenuProps<Item = MenuItem> {
  items?: Item[];
  loading?: boolean;
  scrollable?: boolean;
  onClose: () => void;
  openedViaKeyboard: boolean;
  renderItem?: RenderItemFn<Item>;
  renderHeader?: RenderHeaderFn<Item>;
  onItemClick?: ItemClickFn<Item>;
}

export const DropdownMenuItemContent: React.FC<{ item: MenuItem }> = ({
  item,
}) => {
  if (item === null) {
    return null;
  }

  const { text, description, icon, iconId } = item;
  return (
    <>
      {icon && (
        <Icon
          icon={icon}
          id={iconId ?? text.toLowerCase().replaceAll(/[^a-z]+/g, '-')}
        />
      )}
      <span className='dropdown-menu__item-content'>
        {text}
        {Boolean(description) && (
          <span className='dropdown-menu__item-subtitle'>{description}</span>
        )}
      </span>
    </>
  );
};

export const DropdownMenu = <Item = MenuItem>({
  items,
  loading,
  scrollable,
  onClose,
  openedViaKeyboard,
  renderItem,
  renderHeader,
  onItemClick,
}: DropdownMenuProps<Item>) => {
  const nodeRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleDocumentClick = (e: MouseEvent) => {
      if (
        e.target instanceof Node &&
        nodeRef.current &&
        !nodeRef.current.contains(e.target)
      ) {
        onClose();
        e.stopPropagation();
        e.preventDefault();
      }
    };

    const handleKeyDown = (e: KeyboardEvent) => {
      if (!nodeRef.current) {
        return;
      }

      const items = Array.from(nodeRef.current.querySelectorAll('a, button'));
      const index = document.activeElement
        ? items.indexOf(document.activeElement)
        : -1;

      let element: Element | undefined;

      switch (e.key) {
        case 'ArrowDown':
          element = items[index + 1] ?? items[0];
          break;
        case 'ArrowUp':
          element = items[index - 1] ?? items[items.length - 1];
          break;
        case 'Tab':
          if (e.shiftKey) {
            element = items[index - 1] ?? items[items.length - 1];
          } else {
            element = items[index + 1] ?? items[0];
          }
          break;
        case 'Home':
          element = items[0];
          break;
        case 'End':
          element = items[items.length - 1];
          break;
        case 'Escape':
          onClose();
          break;
      }

      if (element && element instanceof HTMLElement) {
        element.focus();
        e.preventDefault();
        e.stopPropagation();
      }
    };

    document.addEventListener('click', handleDocumentClick, { capture: true });
    document.addEventListener('keydown', handleKeyDown, { capture: true });

    if (openedViaKeyboard) {
      const firstMenuItem = nodeRef.current?.querySelector<
        HTMLAnchorElement | HTMLButtonElement
      >('li:first-child > :is(a, button)');
      firstMenuItem?.focus({ preventScroll: true });
    }

    return () => {
      document.removeEventListener('click', handleDocumentClick, {
        capture: true,
      });
      document.removeEventListener('keydown', handleKeyDown, { capture: true });
    };
  }, [onClose, openedViaKeyboard]);

  const handleItemClick = useCallback(
    (e: React.MouseEvent | React.KeyboardEvent) => {
      const i = Number(e.currentTarget.getAttribute('data-index'));
      const item = items?.[i];
      const isItemDisabled = Boolean(
        item && typeof item === 'object' && 'disabled' in item && item.disabled,
      );

      if (!item || isItemDisabled) {
        return;
      }

      onClose();

      if (typeof onItemClick === 'function') {
        e.preventDefault();
        onItemClick(item, i);
      } else if (isActionItem(item)) {
        e.preventDefault();
        item.action(e);
      }
    },
    [onClose, onItemClick, items],
  );

  const nativeRenderItem = (option: Item, i: number) => {
    if (!isMenuItem(option)) {
      return null;
    }

    if (option === null) {
      return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
    }

    const { text, highlighted, disabled, dangerous } = option;

    let element: React.ReactElement;

    if (isActionItem(option)) {
      element = (
        <button
          onClick={handleItemClick}
          data-index={i}
          aria-disabled={disabled}
          type='button'
        >
          <DropdownMenuItemContent item={option} />
        </button>
      );
    } else if (isExternalLinkItem(option)) {
      element = (
        <a
          href={option.href}
          target={option.target ?? '_target'}
          data-method={option.method}
          rel='noopener'
          onClick={handleItemClick}
          data-index={i}
        >
          <DropdownMenuItemContent item={option} />
        </a>
      );
    } else {
      element = (
        <Link to={option.to} onClick={handleItemClick} data-index={i}>
          <DropdownMenuItemContent item={option} />
        </Link>
      );
    }

    return (
      <li
        className={classNames('dropdown-menu__item', {
          'dropdown-menu__item--highlighted': highlighted,
          'dropdown-menu__item--dangerous': dangerous,
        })}
        key={`${text}-${i}`}
      >
        {element}
      </li>
    );
  };

  const renderItemMethod = renderItem ?? nativeRenderItem;

  return (
    <div
      className={classNames('dropdown-menu__container', {
        'dropdown-menu__container--loading': loading,
      })}
      ref={nodeRef}
    >
      {(loading || !items) && <CircularProgress size={30} strokeWidth={3.5} />}

      {!loading && renderHeader && items && (
        <div className='dropdown-menu__container__header'>
          {renderHeader(items)}
        </div>
      )}

      {!loading && items && (
        <ul
          className={classNames('dropdown-menu__container__list', {
            'dropdown-menu__container__list--scrollable': scrollable,
          })}
        >
          {items.map((option, i) =>
            renderItemMethod(option, i, handleItemClick),
          )}
        </ul>
      )}
    </div>
  );
};

interface DropdownProps<Item extends object | null = MenuItem> {
  children?: React.ReactElement;
  icon?: string;
  iconComponent?: IconProp;
  items?: Item[];
  loading?: boolean;
  title?: string;
  disabled?: boolean;
  scrollable?: boolean;
  placement?: Placement;
  offset?: OffsetValue;
  /**
   * Prevent the `ScrollableList` with this scrollKey
   * from being scrolled while the dropdown is open
   */
  scrollKey?: string;
  status?: ImmutableMap<string, unknown>;
  needsStatusRefresh?: boolean;
  forceDropdown?: boolean;
  className?: string;
  renderItem?: RenderItemFn<Item>;
  renderHeader?: RenderHeaderFn<Item>;
  onOpen?: // Must use a union type for the full function as a union with void is not allowed.
    | ((event: React.MouseEvent | React.KeyboardEvent) => void)
    | ((event: React.MouseEvent | React.KeyboardEvent) => boolean);
  onItemClick?: ItemClickFn<Item>;
}

const popperConfig = { strategy: 'fixed' } as UsePopperOptions;

export const Dropdown = <Item extends object | null = MenuItem>({
  children,
  icon,
  iconComponent,
  items,
  loading,
  title = 'Menu',
  disabled,
  scrollable,
  placement = 'bottom',
  offset = [5, 5],
  status,
  needsStatusRefresh,
  forceDropdown = false,
  className,
  renderItem,
  renderHeader,
  onOpen,
  onItemClick,
  scrollKey,
}: DropdownProps<Item>) => {
  const dispatch = useAppDispatch();
  const openDropdownId = useAppSelector((state) => state.dropdownMenu.openId);
  const openedViaKeyboard = useAppSelector(
    (state) => state.dropdownMenu.keyboard,
  );
  const [currentId] = useState(id++);
  const open = currentId === openDropdownId;
  const buttonRef = useRef<HTMLButtonElement | null>(null);
  const menuId = useId();
  const prefetchAccountId = status
    ? status.getIn(['account', 'id'])
    : undefined;
  const statusId = status?.get('id') as string | undefined;

  const handleClose = useCallback(() => {
    if (buttonRef.current) {
      buttonRef.current.focus({ preventScroll: true });
    }

    dispatch(
      closeModal({
        modalType: 'ACTIONS',
        ignoreFocus: false,
      }),
    );

    dispatch(closeDropdownMenu({ id: currentId }));
  }, [dispatch, currentId]);

  const handleItemClick = useCallback(
    (e: React.MouseEvent) => {
      const i = Number(e.currentTarget.getAttribute('data-index'));
      const item = items?.[i];

      handleClose();

      if (!item) {
        return;
      }

      if (typeof onItemClick === 'function') {
        e.preventDefault();
        onItemClick(item, i);
      } else if (isActionItem(item)) {
        e.preventDefault();
        item.action(e);
      }
    },
    [handleClose, onItemClick, items],
  );

  const isKeypressRef = useRef(false);

  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === ' ' || e.key === 'Enter') {
      isKeypressRef.current = true;
    }
  }, []);

  const unsetIsKeypress = useCallback(() => {
    isKeypressRef.current = false;
  }, []);

  const toggleDropdown = useCallback(
    (e: React.MouseEvent) => {
      if (open) {
        handleClose();
      } else {
        const allow = onOpen?.(e);
        if (allow === false) {
          return;
        }

        if (prefetchAccountId) {
          dispatch(fetchRelationships([prefetchAccountId]));
        }

        if (needsStatusRefresh && statusId) {
          dispatch(
            fetchStatus(statusId, {
              forceFetch: true,
              alsoFetchContext: false,
            }),
          );
        }

        if (isUserTouching() && !forceDropdown) {
          dispatch(
            openModal({
              modalType: 'ACTIONS',
              modalProps: {
                actions: items,
                onClick: handleItemClick,
                className,
              },
            }),
          );
        } else {
          dispatch(
            openDropdownMenu({
              id: currentId,
              keyboard: isKeypressRef.current,
              scrollKey,
            }),
          );
          isKeypressRef.current = false;
        }
      }
    },
    [
      dispatch,
      currentId,
      prefetchAccountId,
      scrollKey,
      onOpen,
      handleItemClick,
      open,
      items,
      forceDropdown,
      handleClose,
      statusId,
      needsStatusRefresh,
      className,
    ],
  );

  useEffect(() => {
    return () => {
      if (currentId === openDropdownId) {
        handleClose();
      }
    };
  }, [currentId, openDropdownId, handleClose]);

  let button: React.ReactElement;

  const buttonProps = {
    disabled,
    onClick: toggleDropdown,
    onKeyDown: handleKeyDown,
    onKeyUp: unsetIsKeypress,
    onBlur: unsetIsKeypress,
    'aria-expanded': open,
    'aria-controls': menuId,
    ref: buttonRef,
  };

  if (children) {
    button = cloneElement(Children.only(children), buttonProps);
  } else if (icon && iconComponent) {
    button = (
      <IconButton
        icon={!open ? icon : 'close'}
        iconComponent={iconComponent}
        title={title}
        active={open}
        {...buttonProps}
      />
    );
  } else {
    return null;
  }

  return (
    <>
      {button}

      <Overlay
        show={open}
        offset={offset}
        placement={placement}
        flip
        target={buttonRef}
        popperConfig={popperConfig}
      >
        {({ props, arrowProps, placement }) => (
          <div {...props} className={className} id={menuId}>
            <div className={`dropdown-animation dropdown-menu ${placement}`}>
              <div
                className={`dropdown-menu__arrow ${placement}`}
                {...arrowProps}
              />

              <DropdownMenu
                items={items}
                loading={loading}
                scrollable={scrollable}
                onClose={handleClose}
                openedViaKeyboard={openedViaKeyboard}
                renderItem={renderItem}
                renderHeader={renderHeader}
                onItemClick={onItemClick}
              />
            </div>
          </div>
        )}
      </Overlay>
    </>
  );
};
