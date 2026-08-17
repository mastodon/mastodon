import type React from 'react';
import {
  createContext,
  use,
  useCallback,
  useId,
  useMemo,
  useState,
} from 'react';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

import { Button } from '../button/redesign';
import { Icon } from '../icon';
import type { IconProp } from '../icon';

import { PopoverMenuCard } from './card';
import type { PopoverMenuCardProps } from './card';
import classes from './styles.module.scss';

export const menuItemClass = classes.menuItem;

interface PopoverState {
  isMenuOpen: boolean;
  toggleMenu: () => void;
  openMenu: () => void;
  closeMenu: () => void;
  popover: HTMLDivElement | null;
  reference: HTMLButtonElement | null;
}

interface MenuButtonContextProps {
  ref: (button: HTMLButtonElement | null) => void;
  id: string;
  'aria-haspopup': 'menu';
  'aria-expanded': boolean;
  'aria-controls'?: string;
  onKeyDown: React.KeyboardEventHandler<HTMLButtonElement>;
  onClick: React.MouseEventHandler<HTMLButtonElement>;
}

interface MenuListContextProps {
  ref: (button: HTMLDivElement | null) => void;
  role: 'menu';
  tabIndex: -1;
  id: string;
  'aria-labelledby': string;
  onKeyDown: React.KeyboardEventHandler<HTMLDivElement>;
}

interface MenuState {
  popover: PopoverState;
  menuButtonProps: MenuButtonContextProps;
  menuListProps: MenuListContextProps;
}

const MenuContext = createContext<MenuState | null>(null);

export function useMenuContext(): MenuState {
  const context = use(MenuContext);

  if (!context) {
    throw new Error('useMenu must be used within a <Menu> component');
  }

  return context;
}

function getAllMenuItems(menuListElement: HTMLDivElement) {
  return Array.from(
    menuListElement.querySelectorAll<HTMLElement>(
      ':scope [data-menu-item]:not([disabled], [aria-disabled])',
    ),
  );
}

export const Menu: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const id = useId();
  const buttonId = `${id}-button`;
  const listId = `${id}-list`;
  const [buttonElement, setButtonElement] = useState<HTMLButtonElement | null>(
    null,
  );
  const [listElement, setListElement] = useState<HTMLDivElement | null>(null);

  const mountListElement = useCallback((element: HTMLDivElement | null) => {
    setListElement(element);
    if (element) {
      const menuItems = getAllMenuItems(element);
      const elementToFocus = menuItems[0] ?? element;
      elementToFocus.focus();
    }
  }, []);

  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const openMenu = useCallback(() => {
    setIsMenuOpen(true);
  }, []);

  const closeMenu = useCallback(() => {
    setIsMenuOpen(false);
    buttonElement?.focus();
  }, [buttonElement]);

  const toggleMenu = isMenuOpen ? closeMenu : openMenu;

  const handleMenuNavigation = useCallback(
    (event: React.KeyboardEvent<HTMLElement>) => {
      if (!listElement) return;

      const menuItems = getAllMenuItems(listElement);
      if (menuItems.length === 0) return;

      const activeElement = document.activeElement as HTMLElement;
      const currentIndex = menuItems.indexOf(activeElement);

      switch (event.code) {
        case 'ArrowDown': {
          event.preventDefault();
          if (isMenuOpen) {
            const nextIndex =
              currentIndex === -1 ? 0 : (currentIndex + 1) % menuItems.length;
            menuItems[nextIndex]?.focus();
          } else {
            openMenu();
          }
          break;
        }

        case 'ArrowUp': {
          event.preventDefault();
          const prevIndex =
            currentIndex === -1
              ? menuItems.length - 1
              : (currentIndex - 1 + menuItems.length) % menuItems.length;
          menuItems[prevIndex]?.focus();
          break;
        }

        case 'Home': {
          event.preventDefault();
          menuItems[0]?.focus();
          break;
        }

        case 'End': {
          event.preventDefault();
          menuItems[menuItems.length - 1]?.focus();
          break;
        }

        case 'Escape': {
          event.preventDefault();
          closeMenu();
          break;
        }
      }
    },
    [closeMenu, isMenuOpen, listElement, openMenu],
  );

  const contextValue = useMemo(() => {
    const popover: PopoverState = {
      isMenuOpen,
      openMenu,
      closeMenu,
      toggleMenu,
      reference: buttonElement,
      popover: listElement,
    };

    const menuButtonProps: MenuButtonContextProps = {
      id: buttonId,
      ref: setButtonElement,
      'aria-haspopup': 'menu',
      'aria-expanded': isMenuOpen,
      'aria-controls': listElement ? listId : undefined,
      onClick: toggleMenu,
      onKeyDown: handleMenuNavigation,
    };

    const menuListProps: MenuListContextProps = {
      id: listId,
      ref: mountListElement,
      'aria-labelledby': buttonId,
      role: 'menu',
      tabIndex: -1,
      onKeyDown: handleMenuNavigation,
    };

    return {
      popover,
      menuButtonProps,
      menuListProps,
    };
  }, [
    isMenuOpen,
    openMenu,
    closeMenu,
    toggleMenu,
    buttonElement,
    listElement,
    mountListElement,
    buttonId,
    listId,
    handleMenuNavigation,
  ]);

  return <MenuContext value={contextValue}>{children}</MenuContext>;
};

export type MenuButtonProps<As extends React.ElementType> = Merge<
  React.ComponentProps<As>,
  {
    as?: As;
  }
>;

export const MenuButton = <As extends React.ElementType>({
  as: asComp,
  children,
  ...props
}: MenuButtonProps<As>) => {
  const Component = asComp ?? Button;
  const { menuButtonProps } = useMenuContext();
  return (
    <Component {...props} {...menuButtonProps}>
      {children}
    </Component>
  );
};

export type MenuListProps<As extends React.ElementType> = Omit<
  PopoverMenuCardProps<As>,
  'isOpen' | 'onClose' | 'reference' | 'popoverElement'
>;

export const MenuList = <As extends React.ElementType>({
  children,
  ...props
}: MenuListProps<As>) => {
  const { popover, menuListProps } = useMenuContext();

  return (
    <PopoverMenuCard
      isOpen={popover.isMenuOpen}
      onClose={popover.closeMenu}
      reference={popover.reference}
      popoverElement={popover.popover}
      container={null}
      {...props}
      {...menuListProps}
    >
      {children}
    </PopoverMenuCard>
  );
};

type MenuItemProps<As extends React.ElementType> = Merge<
  {
    as?: As;
    children?: React.ReactNode;
    className?: string;
    active?: boolean;
    disabled?: boolean;
    leadingIcon?: IconProp;
    trailingIcon?: IconProp;
    iconClassName?: string;
  },
  React.ComponentPropsWithoutRef<As>
>;

export const MenuItemBase = <As extends React.ElementType>({
  active,
  disabled,
  as: AsComp,
  children,
  className,
  leadingIcon,
  trailingIcon,
  iconClassName,
  ...props
}: MenuItemProps<As>) => {
  const Component = AsComp ?? 'div';
  return (
    <Component
      {...props}
      data-menu-item
      className={classNames(
        className,
        classes.menuItem,
        active && classes.menuItemActive,
      )}
      aria-disabled={disabled}
    >
      {leadingIcon && (
        <Icon
          id='menu'
          icon={leadingIcon}
          className={classNames(iconClassName, classes.menuItemIcon)}
        />
      )}

      {children}

      {trailingIcon && (
        <Icon
          id='menu'
          icon={trailingIcon}
          className={classNames(iconClassName, classes.menuItemIcon)}
        />
      )}
    </Component>
  );
};

export const MenuItem: React.FC<Omit<MenuItemProps<'button'>, 'as'>> = ({
  children,
  className,
  ...props
}) => {
  return (
    <MenuItemBase
      as='button'
      type='button'
      role='menuitem'
      {...props}
      className={className}
    >
      {children}
    </MenuItemBase>
  );
};
