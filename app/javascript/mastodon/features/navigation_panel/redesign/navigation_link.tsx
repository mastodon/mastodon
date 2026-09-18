import type { ReactNode, SVGProps } from 'react';

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
        type={as === 'button' ? 'button' : undefined}
        className={classNames(classes.link, stacked && classes.linkStacked)}
      >
        {IconComp && (
          <span className={classes.icon}>
            <IconComp
              size={stacked ? 24 : 20}
              weight={isActive ? 'fill' : undefined}
            />
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

type MobileNavLink = NavLinkProps & {
  withDot?: boolean;
  children: ReactNode;
  iconComponent: Icon | React.FC<SVGProps<SVGSVGElement>>;
};

export const MobileNavLink: React.FC<MobileNavLink> = ({
  iconComponent: IconComp,
  withDot,
  children,
  ...otherProps
}) => {
  const isActive = useIsLinkActive(
    'to' in otherProps ? otherProps.to : undefined,
  );

  return (
    <li>
      <NavLink
        {...otherProps}
        className={classNames(classes.link, classes.linkMobile)}
      >
        <span
          className={classNames(classes.icon, withDot && classes.iconWithDot)}
        >
          <IconComp size={24} weight={isActive ? 'fill' : undefined} />
        </span>
        <span className='sr-only'>{children}</span>
      </NavLink>
    </li>
  );
};

export const MobileNavProfileButton: React.FC<
  { avatar?: ReactNode } & Pick<MobileNavLink, 'children' | 'withDot'>
> = ({ children, avatar, withDot, ...otherProps }) => {
  return (
    <li>
      <button
        type='button'
        {...otherProps}
        className={classNames(classes.link, classes.linkMobile)}
      >
        <span
          className={classNames(classes.icon, withDot && classes.iconWithDot)}
        >
          {avatar}
        </span>
        <span className='sr-only'>{children}</span>
      </button>
    </li>
  );
};
