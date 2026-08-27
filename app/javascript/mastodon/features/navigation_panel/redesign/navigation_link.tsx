import type { SVGProps } from 'react';

import classNames from 'classnames';
import { NavLink } from 'react-router-dom';
import type { NavLinkProps } from 'react-router-dom';

import type { Icon } from '@phosphor-icons/react';

import { Badge } from '@/mastodon/components/badge';
import { useIsLinkActive } from '@/mastodon/hooks/useIsLinkActive';

import classes from './navigation_link.module.scss';

type NavigationLinkProps = {
  stacked?: boolean;
  iconComponent?: Icon | React.FC<SVGProps<SVGSVGElement>>;
  badgeCount?: number;
  withSpaceAfter?: boolean;
} & (
  | ({ as?: 'button' } & React.ComponentPropsWithRef<'button'>)
  | ({ as?: 'link' } & NavLinkProps)
);

export const NavigationLink: React.FC<NavigationLinkProps> = ({
  stacked = false,
  as = 'link',
  iconComponent: IconComp,
  badgeCount = 0,
  withSpaceAfter,
  children,
  ...otherProps
}) => {
  let Comp: React.ElementType = as;
  if (as === 'link') {
    Comp = NavLink;
  }

  const isActive = useIsLinkActive(
    'to' in otherProps ? otherProps.to : undefined,
  );

  return (
    <li
      className={classNames(
        classes.wrapper,
        withSpaceAfter && classes.wrapperWithSpace,
      )}
    >
      <Comp
        {...otherProps}
        className={classNames(classes.link, stacked && classes.linkStacked)}
      >
        {IconComp && (
          <span className={classes.icon}>
            <IconComp size={20} weight={isActive ? 'fill' : undefined} />
          </span>
        )}
        <span className={classes.label}>{children}</span>
        {badgeCount > 0 && (
          <Badge
            variant='accent'
            label={badgeCount}
            className={classes.badge}
          />
        )}
      </Comp>
    </li>
  );
};
