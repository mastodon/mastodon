import classNames from 'classnames';
import { Link } from 'react-router-dom';

import classes from './styles.module.scss';

interface WrapperProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'title'
> {
  icon?: React.ReactNode;
  iconEnd?: React.ReactNode;
}

/**
 * A basic list item component that can be used as a base for more bespoke list items.
 *
 * Depending on functionality, use `ListItemButton` or `ListItemLink` as a child of the
 * wrapper component.
 */
export const ListItemWrapper: React.FC<WrapperProps> = ({
  icon,
  iconEnd,
  children,
  className,
  ...otherProps
}) => {
  return (
    <div {...otherProps} className={classNames(classes.wrapper, className)}>
      {icon}
      <div>{children}</div>
      {iconEnd && <span className={classes.iconEnd}>{iconEnd}</span>}
    </div>
  );
};

interface LinkProps extends React.ComponentPropsWithoutRef<typeof Link> {
  subtitle?: React.ReactNode;
}

export const ListItemLink: React.FC<LinkProps> = ({
  subtitle,
  children,
  className,
  ...otherProps
}) => {
  return (
    <>
      <h3 className={classes.title}>
        <Link className={classNames(className, 'focusable')} {...otherProps}>
          {children}
        </Link>
      </h3>
      {subtitle && <div className={classes.subtitle}>{subtitle}</div>}
    </>
  );
};

interface ButtonProps extends React.ComponentPropsWithoutRef<'button'> {
  subtitle?: React.ReactNode;
}

export const ListItemButton: React.FC<ButtonProps> = ({
  subtitle,
  children,
  className,
  ...otherProps
}) => {
  return (
    <>
      <h3 className={classes.title}>
        <button
          type='button'
          className={classNames(className, 'focusable')}
          {...otherProps}
        >
          {children}
        </button>
      </h3>
      {subtitle && <div className={classes.subtitle}>{subtitle}</div>}
    </>
  );
};
