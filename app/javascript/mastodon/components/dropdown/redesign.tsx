import type React from 'react';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

import { Icon } from '../icon';
import type { IconProp } from '../icon';
import type { PopoverProps } from '../popover';
import { Popover } from '../popover';

import classes from './redesign.module.scss';

export const menuItemClass = classes.menuItem;

export interface DropdownProps {
  children: React.ReactNode;
  elevation?: 1 | 2;
}

export const DropdownPopover: React.FC<
  DropdownProps & React.ComponentProps<'div'> & Omit<PopoverProps, 'children'>
> = ({
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
  ...props
}) => {
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
        <Dropdown {...props} {...popoverChildProps}>
          {children}
        </Dropdown>
      )}
    </Popover>
  );
};

export const Dropdown: React.FC<
  DropdownProps & React.ComponentProps<'div'>
> = ({ children, className, elevation = 1, ...props }) => {
  return (
    <div
      {...props}
      className={classNames(className, classes.menu)}
      data-elevation={elevation}
    >
      {children}
    </div>
  );
};

type DropdownItemProps<As extends React.ElementType> = Merge<
  { as?: As; children: React.ReactNode; className?: string; active?: boolean },
  React.ComponentPropsWithoutRef<As>
>;

export const DropdownItem = <As extends React.ElementType = 'div'>({
  active,
  as: AsComp,
  children,
  className,
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
      )}
    >
      {children}
    </Component>
  );
};

export const DropdownItemButton: React.FC<
  { icon?: IconProp } & React.ComponentProps<'button'>
> = ({ icon, children, className, ...props }) => {
  return (
    <DropdownItem
      type='button'
      {...props}
      as='button'
      className={classNames(className, classes.menuItemButton)}
    >
      {icon && <Icon id='menu' icon={icon} />}
      {children}
    </DropdownItem>
  );
};
