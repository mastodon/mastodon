import { Fragment, useCallback, useId } from 'react';

import classNames from 'classnames';
import type { NavLinkProps } from 'react-router-dom';
import { NavLink } from 'react-router-dom';

import { CheckIcon } from '@phosphor-icons/react';

import { Toggle } from '../form_fields/redesign';
import { Icon } from '../icon';
import type { IconProp } from '../icon';

import { useMenuContext } from '.';
import classes from './styles.module.scss';

interface MenuItemGroupProps extends React.ComponentProps<'div'> {
  label: React.ReactNode;
}

export const MenuItemGroup: React.FC<MenuItemGroupProps> = ({
  label,
  children,
}) => {
  const { type } = useMenuContext();
  const uniqueId = useId();

  // Use list elements if we're in a navigation menu
  const Wrapper = type === 'navigation' ? 'li' : 'div';

  return (
    <Wrapper aria-labelledby={uniqueId} role='group'>
      <div id={uniqueId} className={classes.itemGroupLabel}>
        {label}
      </div>
      {type === 'navigation' ? <ul>{children}</ul> : children}
    </Wrapper>
  );
};

export const MenuItemDivider: React.FC = () => {
  return <hr className={classes.itemDivider} />;
};

type MenuItemProps<As extends React.ElementType> =
  React.ComponentPropsWithoutRef<As> & {
    as?: As;
    children?: React.ReactNode;
    className?: string;
    active?: boolean;
    disabled?: boolean;
    icon?: IconProp | 'reserve-space';
    trailingContent?: React.ReactNode;
    iconClassName?: string;
    keepMenuOpenOnClick?: boolean;
    onClick?: React.MouseEventHandler;
  };

const MenuItemBase = <As extends React.ElementType>({
  active,
  disabled,
  as: AsComp,
  children,
  className,
  icon,
  trailingContent,
  iconClassName,
  keepMenuOpenOnClick,
  onClick,
  ...props
}: MenuItemProps<As>) => {
  const Component = AsComp ?? 'div';
  const { popover } = useMenuContext();

  const closeMenuOnClick = useCallback<React.MouseEventHandler>(
    (e) => {
      if (!keepMenuOpenOnClick) {
        // Closing with a short delay feels nicer than an instant close
        setTimeout(() => {
          popover.closeMenu();
        }, 100);
      }

      onClick?.(e);
    },
    [keepMenuOpenOnClick, onClick, popover],
  );

  return (
    <Component
      // If it's a button, set the type by default or it will submit forms.
      type={AsComp === 'button' ? 'button' : undefined}
      {...props}
      data-menu-item
      className={classNames(
        className,
        classes.item,
        active && classes.itemActive,
      )}
      aria-disabled={disabled}
      onClick={closeMenuOnClick}
    >
      {icon && icon !== 'reserve-space' && (
        <Icon
          id='menu'
          icon={icon}
          className={classNames(iconClassName, classes.itemIcon)}
        />
      )}
      {icon === 'reserve-space' && <div className={classes.itemIcon} />}

      {children}

      {trailingContent && (
        <span className={classes.itemTrailingContent}>{trailingContent}</span>
      )}
    </Component>
  );
};

export const MenuItem: React.FC<Omit<MenuItemProps<'button'>, 'as'>> = ({
  children,
  ...props
}) => {
  const { type } = useMenuContext();

  const Wrapper = type === 'actions' ? Fragment : 'li';

  return (
    <Wrapper>
      <MenuItemBase
        as='button'
        type='button'
        role={type === 'actions' ? 'menuitem' : undefined}
        {...props}
      >
        {children}
      </MenuItemBase>
    </Wrapper>
  );
};

type MenuItemLinkProps = Omit<MenuItemProps<'a'>, 'as'> &
  (
    | ({ as: 'a' } & React.ComponentProps<'a'>)
    | ({ as?: 'link' } & NavLinkProps)
  );

export const MenuItemLink: React.FC<MenuItemLinkProps> = ({
  as,
  children,
  onKeyDown,
  ...props
}) => {
  const { type } = useMenuContext();

  const handleSpacebarPress = useCallback(
    (e: React.KeyboardEvent<HTMLAnchorElement>) => {
      if (type === 'actions' && e.code === 'Space') {
        (e.target as HTMLElement).click();
        e.preventDefault();
      }
      onKeyDown?.(e);
    },
    [onKeyDown, type],
  );

  const Wrapper = type === 'actions' ? Fragment : 'li';
  const asElement = (as ?? 'link') === 'link' ? NavLink : 'a';
  const externalLinkProps =
    as === 'a'
      ? {
          target: '_blank',
          rel: 'noopener',
        }
      : undefined;

  return (
    <Wrapper>
      <MenuItemBase
        as={asElement}
        role={type === 'actions' ? 'menuitem' : undefined}
        onKeyDown={handleSpacebarPress}
        {...externalLinkProps}
        {...props}
      >
        {children}
      </MenuItemBase>
    </Wrapper>
  );
};

// Helper to prevent item components from being used with incompatible menu types
function useAssertMenuType(componentName: string) {
  const { type } = useMenuContext();

  if (type === 'navigation') {
    throw new Error(
      `\`${componentName}\` can not be used inside of \`<Menu type='navigation'>\`. Use \`type='actions'\` instead.`,
    );
  }
}

interface MenuItemRadioProps extends Omit<
  MenuItemProps<'button'>,
  'as' | 'onChange' | 'icon'
> {
  checked: boolean;
  value: string;
  onChange?: (change: { value: string }) => void;
}

export const MenuItemRadio: React.FC<MenuItemRadioProps> = ({
  children,
  checked,
  value,
  onChange,
  ...props
}) => {
  useAssertMenuType('MenuItemRadio');

  const handleChange = useCallback(() => {
    onChange?.({ value });
  }, [value, onChange]);

  return (
    <MenuItemBase
      as='button'
      {...props}
      role='menuitemradio'
      aria-checked={checked}
      onClick={handleChange}
      icon={checked ? CheckIcon : 'reserve-space'}
    >
      {children}
    </MenuItemBase>
  );
};

interface MenuItemCheckboxProps extends Omit<MenuItemRadioProps, 'onChange'> {
  icon?: IconProp;
  onChange?: (change: { value: string; checked: boolean }) => void;
}

export const MenuItemCheckbox: React.FC<MenuItemCheckboxProps> = ({
  children,
  checked,
  value,
  onChange,
  ...props
}) => {
  useAssertMenuType('MenuItemCheckbox');

  const handleChange = useCallback(() => {
    onChange?.({ value, checked: !checked });
  }, [onChange, value, checked]);

  return (
    <MenuItemBase
      as='button'
      {...props}
      role='menuitemcheckbox'
      aria-checked={checked}
      onClick={handleChange}
      trailingContent={
        <Toggle
          aria-hidden='true'
          tabIndex={-1}
          size='sm'
          checked={checked}
          readOnly
        />
      }
    >
      {children}
    </MenuItemBase>
  );
};
