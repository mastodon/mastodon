import type { ComponentPropsWithoutRef, FC } from 'react';

import classNames from 'classnames';
import type { NavLinkProps } from 'react-router-dom';
import { NavLink } from 'react-router-dom';

import classes from './styles.module.scss';

interface TabListProps {
  /**
   * Setting this will remove the default border and
   * horizontal padding from the component
   */
  plain?: boolean;
}

/**
 * Display a simple row of links as tabs.
 * The current page will be highlighted automatically based on the link destination.
 */
export const TabList: FC<TabListProps & ComponentPropsWithoutRef<'div'>> = ({
  plain,
  className,
  children,
  ...otherProps
}) => {
  return (
    <div
      {...otherProps}
      className={classNames(
        className,
        classes.tabList,
        !plain && classes.withSpaceAndBorder,
      )}
    >
      {children}
    </div>
  );
};

export const TabLink: FC<NavLinkProps> = ({
  className,
  children,
  ...otherProps
}) => {
  return (
    <NavLink className={classNames(classes.tab, className)} {...otherProps}>
      {children}
    </NavLink>
  );
};
