import type React from 'react';

import classNames from 'classnames';

import type { IconProp } from '../icon';
import { Icon } from '../icon';

import classes from './redesign.module.scss';

interface ButtonPropsBase {
  size?: 'lg' | 'md' | 'sm' | 'xs';
  variant?: 'solid' | 'text';
  color?: 'accent' | 'neutral' | 'tonal' | 'destructive';
}

type ButtonProps<As extends 'a' | 'button' = 'button'> = {
  as?: As;
} & ButtonPropsBase &
  React.ComponentPropsWithRef<As>;

export const BaseButton: React.FC<
  Omit<ButtonProps, 'label' | 'leadingIcon' | 'trailingIcon'>
> = ({
  size = 'md',
  variant = 'solid',
  color = 'neutral',
  as: Comp = 'button',
  children,
  className,
  ...props
}) => (
  <Comp
    type='button'
    {...props}
    className={classNames(
      className,
      classes.base,
      classes[size],
      classes[color],
      classes[variant],
    )}
  >
    {children}
  </Comp>
);

export const Button: React.FC<
  ButtonProps & {
    label: string;
    leadingIcon?: IconProp;
    trailingIcon?: IconProp;
  }
> = ({ label, leadingIcon, trailingIcon, ...props }) => (
  <BaseButton {...props}>
    {leadingIcon && (
      <Icon id='leading' icon={leadingIcon} className={classes.icon} />
    )}
    {label}
    {trailingIcon && (
      <Icon id='trailing' icon={trailingIcon} className={classes.icon} />
    )}
  </BaseButton>
);

export const IconButton: React.FC<ButtonProps & { icon: IconProp }> = ({
  icon,
  className,
  ...props
}) => (
  <BaseButton {...props} className={classNames(classNames, classes.iconOnly)}>
    <Icon id='icon' icon={icon} className={classes.icon} />
  </BaseButton>
);
