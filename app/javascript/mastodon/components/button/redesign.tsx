import type React from 'react';
import { useCallback } from 'react';

import classNames from 'classnames';

import { CircularProgress } from '../circular_progress';
import type { IconProp } from '../icon';
import { Icon } from '../icon';

import classes from './redesign.module.scss';

interface ButtonPropsBase<As extends 'a' | 'button'> {
  size?: 'lg' | 'md' | 'sm' | 'xs';
  variant?: 'solid' | 'text';
  color?: 'accent' | 'neutral' | 'tonal' | 'destructive';
  onClick?: React.MouseEventHandler<
    As extends 'a' ? HTMLAnchorElement : HTMLButtonElement
  >;
  loading?: boolean;
}

type ButtonProps<As extends 'a' | 'button' = 'button'> = {
  as?: As;
} & ButtonPropsBase<As> &
  React.ComponentPropsWithRef<As>;

export const BaseButton: React.FC<ButtonProps> = ({
  size = 'md',
  variant = 'solid',
  color = 'neutral',
  as: Comp = 'button',
  children,
  className,
  disabled,
  onClick,
  loading,
  ...props
}) => {
  const handleClick: React.MouseEventHandler<HTMLButtonElement> = useCallback(
    (event) => {
      if (disabled || loading) {
        event.stopPropagation();
        event.preventDefault();
      } else if (onClick) {
        onClick(event);
      }
    },
    [loading, onClick, disabled],
  );
  return (
    <Comp
      type='button'
      {...props}
      className={classNames(
        className,
        classes.base,
        classes[size],
        classes[color],
        classes[variant],
        (loading || disabled) && classes.disabled,
      )}
      onClick={handleClick}
      // Disabled buttons can't have focus, so we don't really
      // disable the button during loading
      disabled={disabled && !loading}
      aria-disabled={loading}
      // If the loading prop is used, announce label changes
      aria-live={loading !== undefined ? 'polite' : undefined}
    >
      {children}
    </Comp>
  );
};

export const Button: React.FC<
  ButtonProps & {
    label: string;
    leadingIcon?: IconProp;
    trailingIcon?: IconProp;
  }
> = ({ label, leadingIcon, trailingIcon, ...props }) => (
  <BaseButton {...props}>
    {leadingIcon && !props.loading && (
      <Icon id='leading' icon={leadingIcon} className={classes.icon} />
    )}
    {props.loading && <LoadingIcon />}
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
    {props.loading ? (
      <LoadingIcon />
    ) : (
      <Icon id='icon' icon={icon} className={classes.icon} />
    )}
  </BaseButton>
);

const LoadingIcon: React.FC = () => (
  <CircularProgress
    size={10}
    strokeWidth={1}
    className={classes.loading}
    role='none'
  />
);
