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
 * Choose the child of the wrapper component based on needed interactivity:
 * `ListItemContent` for a non-interactive item, `ListItemButton` or `ListItemLink`
 * for interactive items.
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

interface WithSubtitle {
  subtitle?: React.ReactNode;
}

interface ContentProps
  extends React.ComponentPropsWithoutRef<'h3'>, WithSubtitle {}

export const ListItemContent: React.FC<ContentProps> = ({
  subtitle,
  children,
  ...otherProps
}) => {
  return (
    <>
      <h3 className={classes.title} {...otherProps}>
        {children}
      </h3>
      {subtitle && <div className={classes.subtitle}>{subtitle}</div>}
    </>
  );
};

interface LinkProps
  extends React.ComponentPropsWithoutRef<typeof Link>, WithSubtitle {}

export const ListItemLink: React.FC<LinkProps> = ({
  subtitle,
  children,
  className,
  ...otherProps
}) => {
  return (
    <ListItemContent subtitle={subtitle}>
      <Link className={classNames(className, 'focusable')} {...otherProps}>
        {children}
      </Link>
    </ListItemContent>
  );
};

interface ButtonProps
  extends React.ComponentPropsWithoutRef<'button'>, WithSubtitle {}

export const ListItemButton: React.FC<ButtonProps> = ({
  subtitle,
  children,
  className,
  ...otherProps
}) => {
  return (
    <ListItemContent subtitle={subtitle}>
      <button
        type='button'
        className={classNames(className, 'focusable')}
        {...otherProps}
      >
        {children}
      </button>
    </ListItemContent>
  );
};
