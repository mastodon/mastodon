import { useCallback, useId } from 'react';

import classNames from 'classnames';

import { CheckIcon } from '@phosphor-icons/react';

import { Toggle } from '../form_fields/redesign';
import { Icon } from '../icon';
import type { IconProp } from '../icon';

import classes from './styles.module.scss';

interface MenuItemGroupProps extends React.ComponentProps<'div'> {
  label: React.ReactNode;
}

export const MenuItemGroup: React.FC<MenuItemGroupProps> = ({
  label,
  children,
}) => {
  const uniqueId = useId();

  return (
    <div aria-labelledby={uniqueId} role='group'>
      <div id={uniqueId} className={classes.itemGroupLabel}>
        {label}
      </div>
      {children}
    </div>
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
  };

export const MenuItemBase = <As extends React.ElementType>({
  active,
  disabled,
  as: AsComp,
  children,
  className,
  icon,
  trailingContent,
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
        classes.item,
        active && classes.itemActive,
      )}
      aria-disabled={disabled}
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

      <span className={classes.itemTrailingContent}>{trailingContent}</span>
    </Component>
  );
};

export const MenuItem: React.FC<Omit<MenuItemProps<'button'>, 'as'>> = ({
  children,
  ...props
}) => {
  return (
    <MenuItemBase as='button' type='button' role='menuitem' {...props}>
      {children}
    </MenuItemBase>
  );
};

interface MenuItemRadioProps extends Omit<
  MenuItemProps<'button'>,
  'as' | 'onChange' | 'icon'
> {
  checked: boolean;
  value: string;
  onChange: (change: { value: string }) => void;
}

export const MenuItemRadio: React.FC<MenuItemRadioProps> = ({
  children,
  checked,
  value,
  onChange,
  ...props
}) => {
  const handleChange = useCallback(() => {
    onChange({ value });
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
  onChange: (change: { value: string; checked: boolean }) => void;
}

export const MenuItemCheckbox: React.FC<MenuItemCheckboxProps> = ({
  children,
  checked,
  value,
  onChange,
  ...props
}) => {
  const handleChange = useCallback(() => {
    onChange({ value, checked: !checked });
  }, [onChange, value, checked]);

  return (
    <MenuItemBase
      as='button'
      {...props}
      role='menuitemcheckbox'
      aria-checked={checked}
      onClick={handleChange}
      trailingContent={
        <Toggle aria-hidden='true' tabIndex={-1} size='sm' checked={checked} />
      }
    >
      {children}
    </MenuItemBase>
  );
};
