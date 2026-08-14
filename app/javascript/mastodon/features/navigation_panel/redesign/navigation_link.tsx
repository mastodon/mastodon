import classNames from 'classnames';
import { NavLink, matchPath, useLocation } from 'react-router-dom';
import type { NavLinkProps } from 'react-router-dom';

import type { Icon } from '@phosphor-icons/react';

import { Badge } from '@/mastodon/components/badge';

import classes from './navigation_link.module.scss';

type NavigationLinkProps = {
  iconComponent: Icon;
  badgeCount?: number;
  withSpaceAfter?: boolean;
} & (
  | ({ as?: 'button' } & React.ComponentPropsWithRef<'button'>)
  | ({ as?: 'link' } & NavLinkProps)
);

export const NavigationLink: React.FC<NavigationLinkProps> = ({
  as = 'link',
  iconComponent: IconComp,
  badgeCount = 0,
  withSpaceAfter,
  children,
  ...otherProps
}) => {
  const location = useLocation();

  let Comp: React.ElementType = as;
  if (as === 'link') {
    Comp = NavLink;
  }

  const to = 'to' in otherProps && otherProps.to;
  const isActive =
    to && typeof to !== 'function'
      ? !!matchPath(location.pathname, {
          path: typeof to === 'string' ? to : to.pathname,
        })
      : false;

  return (
    <li
      className={classNames(
        classes.wrapper,
        withSpaceAfter && classes.wrapperWithSpace,
      )}
    >
      <Comp {...otherProps} className={classes.link}>
        <span className={classes.icon}>
          <IconComp size={20} weight={isActive ? 'fill' : undefined} />
        </span>
        <span className={classes.label}>{children}</span>
        {badgeCount > 0 && <Badge variant='accent' label={badgeCount} />}
      </Comp>
    </li>
  );
};
