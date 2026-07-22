import type React from 'react';
import type { ReactNode } from 'react';
import { useCallback } from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';
import type { LinkProps } from 'react-router-dom';

import { CircularProgress } from '../circular_progress';
import type { IconProp } from '../icon';
import { Icon } from '../icon';

import classes from './redesign.module.scss';

interface ButtonPropsBase<As extends 'a' | 'button'> {
  size?: 'lg' | 'md' | 'sm' | 'xs';
  variant?: 'solid' | 'text';
  color?: 'accent' | 'neutral' | 'tonal' | 'destructive';
  onClick?: React.MouseEventHandler<
    As extends 'button' ? HTMLButtonElement : HTMLAnchorElement
  >;
  loading?: boolean;
  children: ReactNode;
}

type ButtonButtonProps = { as?: 'button' } & ButtonPropsBase<'button'> &
  Omit<React.ComponentPropsWithRef<'button'>, 'children'>;
type ButtonAnchorProps = { as: 'a' } & ButtonPropsBase<'a'> &
  Omit<React.ComponentPropsWithRef<'a'>, 'children'>;
type ButtonLinkProps = { as: 'link' } & ButtonPropsBase<'a'> &
  Omit<LinkProps, 'children'>;

type ButtonProps = ButtonButtonProps | ButtonAnchorProps | ButtonLinkProps;

const BaseButton: React.FC<ButtonProps> = ({
  size = 'md',
  variant = 'solid',
  color = 'neutral',
  as: asComp = 'button',
  children,
  className,
  onClick,
  loading,
  'aria-disabled': ariaDisabled,
  'aria-live': ariaLive,
  ...props
}) => {
  const disabled = 'disabled' in props ? props.disabled : false;
  const handleClick: React.MouseEventHandler<
    HTMLButtonElement & HTMLAnchorElement
  > = useCallback(
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

  let Comp: React.ElementType = asComp;
  if (asComp === 'link') {
    Comp = Link;
  }

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
      )}
      onClick={handleClick}
      // Disabled buttons can't have focus, so we don't really
      // disable the button during loading
      disabled={disabled && !loading}
      aria-disabled={loading || ariaDisabled}
      // If the loading prop is used, announce label changes
      aria-live={ariaLive ?? (loading !== undefined ? 'polite' : undefined)}
    >
      {children}
    </Comp>
  );
};

export const Button: React.FC<
  ButtonProps & {
    leadingIcon?: IconProp;
    trailingIcon?: IconProp;
  }
> = ({ children, leadingIcon, trailingIcon, ...props }) => (
  <BaseButton {...props}>
    {leadingIcon && !props.loading && (
      <Icon id='leading' icon={leadingIcon} className={classes.icon} />
    )}
    {props.loading && <LoadingIcon />}
    {children}
    {trailingIcon && (
      <Icon id='trailing' icon={trailingIcon} className={classes.icon} />
    )}
  </BaseButton>
);

export const IconButton: React.FC<ButtonProps & { icon: IconProp }> = ({
  icon,
  className,
  children,
  ...props
}) => (
  <BaseButton {...props} className={classNames(classNames, classes.iconOnly)}>
    {props.loading ? (
      <LoadingIcon />
    ) : (
      <Icon id='icon' icon={icon} className={classes.icon} />
    )}
    <span className='sr-only'>{children}</span>
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
