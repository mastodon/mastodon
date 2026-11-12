import type { ReactNode, SVGProps } from 'react';

import classNames from 'classnames';
import { NavLink } from 'react-router-dom';
import type { NavLinkProps } from 'react-router-dom';

import type { Icon } from '@phosphor-icons/react';

import { Badge } from '@/mastodon/components/badge';
import { Tooltip } from '@/mastodon/components/tooltip';
import { useIsLinkActive } from '@/mastodon/hooks/useIsLinkActive';

import classes from './navigation_link.module.scss';

type NavigationLinkProps = {
  iconComponent?: Icon | React.FC<SVGProps<SVGSVGElement>>;
  badgeCount?: number;
  withDivider?: boolean;
} & (
  | ({ as?: 'button' } & React.ComponentPropsWithRef<'button'>)
  | ({ as?: 'a' } & React.ComponentPropsWithRef<'a'>)
  | ({ as?: 'link' } & NavLinkProps)
);

export const NavigationLink: React.FC<NavigationLinkProps> = ({
  as = 'link',
  iconComponent: IconComp,
  badgeCount = 0,
  withDivider = false,
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
        withDivider && classes.wrapperWithDivider,
      )}
    >
      <Comp
        {...otherProps}
        type={as === 'button' ? 'button' : undefined}
        className={classes.link}
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

type MobileNavLink = NavLinkProps & {
  withDot?: boolean;
  children: ReactNode;
  iconComponent: Icon | React.FC<SVGProps<SVGSVGElement>>;
};

export const MiniNavLink: React.FC<MobileNavLink> = ({
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
      <Tooltip text={children} placement='top' offset={-2}>
        {({ getTooltipProps }) => (
          <NavLink
            {...getTooltipProps(otherProps)}
            className={classNames(classes.link, classes.linkMini)}
          >
            <span
              className={classNames(
                classes.icon,
                withDot && classes.iconWithDot,
              )}
            >
              <IconComp size={24} weight={isActive ? 'fill' : undefined} />
            </span>
            <span className='sr-only'>{children}</span>
          </NavLink>
        )}
      </Tooltip>
    </li>
  );
};

export const MiniNavProfileButton: React.FC<
  { avatar?: ReactNode } & Pick<MobileNavLink, 'children' | 'withDot'>
> = ({ children, avatar, withDot, ...otherProps }) => {
  return (
    <li>
      <Tooltip text={children} placement='top' offset={-2}>
        {({ getTooltipProps }) => (
          <button
            type='button'
            {...getTooltipProps(otherProps)}
            className={classNames(classes.link, classes.linkMini)}
          >
            <span
              className={classNames(
                classes.icon,
                withDot && classes.iconWithDot,
              )}
            >
              {avatar}
            </span>
            <span className='sr-only'>{children}</span>
          </button>
        )}
      </Tooltip>
    </li>
  );
};
