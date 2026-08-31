import type React from 'react';
import type { ReactNode } from 'react';
import { useCallback } from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';
import type { LinkProps } from 'react-router-dom';

import { CaretDownIcon } from '@phosphor-icons/react';

import { CircularProgress } from '../circular_progress';
import type { IconProp } from '../icon';
import { Icon } from '../icon';

import classes from './redesign.module.scss';

export const buttonClasses = classes;

interface ButtonPropsBase<As extends 'a' | 'button'> {
  size?: 'lg' | 'md' | 'sm' | 'xs';
  variant?: 'solid' | 'tonal' | 'ghost';
  color?: 'accent' | 'neutral' | 'destructive';
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

type BaseButtonProps = ButtonButtonProps | ButtonAnchorProps | ButtonLinkProps;

const BaseButton: React.FC<BaseButtonProps> = ({
  size = 'md',
  variant = 'tonal',
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

type ButtonProps = BaseButtonProps & {
  leadingIcon?: IconProp;
  trailingIcon?: IconProp;
};

export const Button: React.FC<ButtonProps> = ({
  children,
  leadingIcon,
  trailingIcon,
  ...props
}) => (
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

export type IconButtonProps = BaseButtonProps & {
  icon: IconProp;
};

export const IconButton: React.FC<IconButtonProps> = ({
  icon,
  className,
  children,
  ...props
}) => (
  <BaseButton {...props} className={classNames(className, classes.iconOnly)}>
    {props.loading ? (
      <LoadingIcon />
    ) : (
      <Icon id='icon' icon={icon} className={classes.icon} />
    )}
    <span className='sr-only'>{children}</span>
  </BaseButton>
);

export const CaretIcon = (
  props: React.SVGProps<SVGSVGElement> & { title?: string },
) => (
  <CaretDownIcon
    {...props}
    className={classNames(props.className, classes.iconCustom)}
    weight='fill'
    size={12}
  />
);

const LoadingIcon: React.FC = () => (
  <CircularProgress
    size={10}
    strokeWidth={1}
    className={classes.loading}
    role='none'
  />
);

export const ToggleButton: React.FC<ButtonProps & { active?: boolean }> = ({
  active,
  className,
  ...props
}) => (
  <Button
    aria-pressed={active}
    {...props}
    // Toggle buttons always have neutral until pressed.
    color='neutral'
    className={classNames(className, classes.toggle)}
  />
);
