import type React from 'react';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

import { Icon } from '../icon';
import type { IconProp } from '../icon';
import type { PopoverProps } from '../popover';
import { Popover } from '../popover';

import classes from './redesign.module.scss';

export const menuItemClass = classes.menuItem;

export type DropdownProps<As extends React.ElementType> = Merge<
  {
    as?: As;
    children: React.ReactNode;
    className?: string;
    elevation?: 1 | 2;
    maxWidth?: number | string;
    style?: React.CSSProperties;
  },
  React.ComponentProps<As>
>;

export const DropdownPopover = <As extends React.ElementType>({
  isOpen,
  onClose,
  reference,
  popoverElement,
  container,
  placement,
  offset = 4,
  flip,
  strategy,
  matchReferenceWidth,
  closeOnClickOutside,
  children,
  className,
  ...props
}: DropdownProps<As> & Omit<PopoverProps, 'children'>) => {
  const popoverProps = {
    isOpen,
    onClose,
    reference,
    popoverElement,
    container,
    placement,
    offset,
    flip,
    strategy,
    matchReferenceWidth,
    closeOnClickOutside,
  };
  return (
    <Popover {...popoverProps}>
      {({ props: popoverChildProps }) => (
        <Dropdown
          {...props}
          {...popoverChildProps}
          className={classNames(
            className,
            props.maxWidth && classes.popoverMenu,
          )}
        >
          {children}
        </Dropdown>
      )}
    </Popover>
  );
};

export const Dropdown = <As extends React.ElementType>({
  as: asComp,
  children,
  className,
  elevation = 1,
  maxWidth,
  style,
  ...props
}: DropdownProps<As>) => {
  const Component = asComp ?? 'div';
  return (
    <Component
      {...props}
      className={classNames(className, classes.menu)}
      data-elevation={elevation}
      style={{
        maxWidth: typeof maxWidth === 'number' ? `${maxWidth}px` : maxWidth,
        ...style,
      }}
    >
      {children}
    </Component>
  );
};

type DropdownItemProps<As extends React.ElementType> = Merge<
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

export const DropdownItem = <As extends React.ElementType>({
  active,
  disabled,
  as: AsComp,
  children,
  className,
  leadingIcon,
  trailingIcon,
  iconClassName,
  ...props
}: DropdownItemProps<As>) => {
  const Component = AsComp ?? 'div';
  return (
    <Component
      {...props}
      className={classNames(
        className,
        classes.menuItem,
        active && classes.menuItemActive,
        disabled && classes.menuItemDisabled,
      )}
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

export const DropdownItemButton: React.FC<
  Omit<DropdownItemProps<'button'>, 'as'>
> = ({ children, className, ...props }) => {
  return (
    <DropdownItem
      type='button'
      {...props}
      as='button'
      className={classNames(className, classes.menuItemButton)}
    >
      {children}
    </DropdownItem>
  );
};
