import {
  useState,
  useEffect,
  useRef,
  useCallback,
  cloneElement,
  Children,
} from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { Map as ImmutableMap } from 'immutable';

import Overlay from 'react-overlays/Overlay';
import type {
  OffsetValue,
  UsePopperOptions,
} from 'react-overlays/esm/usePopper';

import { fetchRelationships } from 'mastodon/actions/accounts';
import {
  openDropdownMenu,
  closeDropdownMenu,
} from 'mastodon/actions/dropdown_menu';
import { openModal, closeModal } from 'mastodon/actions/modal';
import { CircularProgress } from 'mastodon/components/circular_progress';
import { isUserTouching } from 'mastodon/is_mobile';
import type {
  MenuItem,
  ActionMenuItem,
  ExternalLinkMenuItem,
} from 'mastodon/models/dropdown_menu';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import type { IconProp } from './icon';
import { IconButton } from './icon_button';

let id = 0;

const isMenuItem = (item: unknown): item is MenuItem => {
  if (item === null) {
    return true;
  }

  return typeof item === 'object' && 'text' in item;
};

const isActionItem = (item: unknown): item is ActionMenuItem => {
  if (!item || !isMenuItem(item)) {
    return false;
  }

  return 'action' in item;
};

const isExternalLinkItem = (item: unknown): item is ExternalLinkMenuItem => {
  if (!item || !isMenuItem(item)) {
    return false;
  }

  return 'href' in item;
};

type RenderItemFn<Item = MenuItem> = (
  item: Item,
  index: number,
  handlers: {
    onClick: (e: React.MouseEvent) => void;
    onKeyUp: (e: React.KeyboardEvent) => void;
  },
) => React.ReactNode;

type RenderHeaderFn<Item = MenuItem> = (items: Item[]) => React.ReactNode;

interface DropdownMenuProps<Item = MenuItem> {
  items?: Item[];
  loading?: boolean;
  scrollable?: boolean;
  onClose: () => void;
  openedViaKeyboard: boolean;
  renderItem?: RenderItemFn<Item>;
  renderHeader?: RenderHeaderFn<Item>;
  onItemClick: (e: React.MouseEvent | React.KeyboardEvent) => void;
}

const DropdownMenu = <Item = MenuItem,>({
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
  const focusedItemRef = useRef<HTMLElement | null>(null);

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

    if (focusedItemRef.current && openedViaKeyboard) {
      focusedItemRef.current.focus({ preventScroll: true });
    }

    return () => {
      document.removeEventListener('click', handleDocumentClick, {
        capture: true,
      });
      document.removeEventListener('keydown', handleKeyDown, { capture: true });
    };
  }, [onClose, openedViaKeyboard]);

  const handleFocusedItemRef = useCallback(
    (c: HTMLAnchorElement | HTMLButtonElement | null) => {
      focusedItemRef.current = c as HTMLElement;
    },
    [],
  );

  const handleItemKeyUp = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' || e.key === ' ') {
        onItemClick(e);
      }
    },
    [onItemClick],
  );

  const handleClick = useCallback(
    (e: React.MouseEvent | React.KeyboardEvent) => {
      onItemClick(e);
    },
    [onItemClick],
  );

  const nativeRenderItem = (option: Item, i: number) => {
    if (!isMenuItem(option)) {
      return null;
    }

    if (option === null) {
      return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
    }

    const { text, dangerous } = option;

    let element: React.ReactElement;

    if (isActionItem(option)) {
      element = (
        <button
          ref={i === 0 ? handleFocusedItemRef : undefined}
          onClick={handleClick}
          onKeyUp={handleItemKeyUp}
          data-index={i}
        >
          {text}
        </button>
      );
    } else if (isExternalLinkItem(option)) {
      element = (
        <a
          href={option.href}
          target={option.target ?? '_target'}
          data-method={option.method}
          rel='noopener'
          ref={i === 0 ? handleFocusedItemRef : undefined}
          onClick={handleClick}
          onKeyUp={handleItemKeyUp}
          data-index={i}
        >
          {text}
        </a>
      );
    } else {
      element = (
        <Link
          to={option.to}
          ref={i === 0 ? handleFocusedItemRef : undefined}
          onClick={handleClick}
          onKeyUp={handleItemKeyUp}
          data-index={i}
        >
          {text}
        </Link>
      );
    }

    return (
      <li
        className={classNames('dropdown-menu__item', {
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
            renderItemMethod(option, i, {
              onClick: handleClick,
              onKeyUp: handleItemKeyUp,
            }),
          )}
        </ul>
      )}
    </div>
  );
};

interface DropdownProps<Item = MenuItem> {
  children?: React.ReactElement;
  icon?: string;
  iconComponent?: IconProp;
  items?: Item[];
  loading?: boolean;
  title?: string;
  disabled?: boolean;
  scrollable?: boolean;
  scrollKey?: string;
  status?: ImmutableMap<string, unknown>;
  renderItem?: RenderItemFn<Item>;
  renderHeader?: RenderHeaderFn<Item>;
  onOpen?: () => void;
  onItemClick?: (arg0: Item, arg1: number) => void;
}

const offset = [5, 5] as OffsetValue;
const popperConfig = { strategy: 'fixed' } as UsePopperOptions;

export const Dropdown = <Item = MenuItem,>({
  children,
  icon,
  iconComponent,
  items,
  loading,
  title = 'Menu',
  disabled,
  scrollable,
  status,
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
  const activeElement = useRef<HTMLElement | null>(null);
  const targetRef = useRef<HTMLButtonElement | null>(null);

  const handleClose = useCallback(() => {
    if (activeElement.current) {
      activeElement.current.focus({ preventScroll: true });
      activeElement.current = null;
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
    (e: React.MouseEvent | React.KeyboardEvent) => {
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
        item.action();
      }
    },
    [handleClose, onItemClick, items],
  );

  const handleClick = useCallback(
    (e: React.MouseEvent | React.KeyboardEvent) => {
      const { type } = e;

      if (open) {
        handleClose();
      } else {
        onOpen?.();

        if (status) {
          dispatch(fetchRelationships([status.getIn(['account', 'id'])]));
        }

        if (isUserTouching()) {
          dispatch(
            openModal({
              modalType: 'ACTIONS',
              modalProps: {
                status,
                actions: items,
                onClick: handleItemClick,
              },
            }),
          );
        } else {
          dispatch(
            openDropdownMenu({
              id: currentId,
              keyboard: type !== 'click',
              scrollKey,
            }),
          );
        }
      }
    },
    [
      dispatch,
      currentId,
      scrollKey,
      onOpen,
      handleItemClick,
      open,
      status,
      items,
      handleClose,
    ],
  );

  const handleMouseDown = useCallback(() => {
    if (!open && document.activeElement instanceof HTMLElement) {
      activeElement.current = document.activeElement;
    }
  }, [open]);

  const handleButtonKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case ' ':
        case 'Enter':
          handleMouseDown();
          break;
      }
    },
    [handleMouseDown],
  );

  const handleKeyPress = useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case ' ':
        case 'Enter':
          handleClick(e);
          e.stopPropagation();
          e.preventDefault();
          break;
      }
    },
    [handleClick],
  );

  useEffect(() => {
    return () => {
      if (currentId === openDropdownId) {
        handleClose();
      }
    };
  }, [currentId, openDropdownId, handleClose]);

  let button: React.ReactElement;

  if (children) {
    button = cloneElement(Children.only(children), {
      onClick: handleClick,
      onMouseDown: handleMouseDown,
      onKeyDown: handleButtonKeyDown,
      onKeyPress: handleKeyPress,
      ref: targetRef,
    });
  } else if (icon && iconComponent) {
    button = (
      <IconButton
        icon={!open ? icon : 'close'}
        iconComponent={iconComponent}
        title={title}
        active={open}
        disabled={disabled}
        onClick={handleClick}
        onMouseDown={handleMouseDown}
        onKeyDown={handleButtonKeyDown}
        onKeyPress={handleKeyPress}
        ref={targetRef}
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
        placement='bottom'
        flip
        target={targetRef}
        popperConfig={popperConfig}
      >
        {({ props, arrowProps, placement }) => (
          <div {...props}>
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
                onItemClick={handleItemClick}
              />
            </div>
          </div>
        )}
      </Overlay>
    </>
  );
};
