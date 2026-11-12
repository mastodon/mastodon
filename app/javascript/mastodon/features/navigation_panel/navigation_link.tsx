import type { ReactNode, SVGProps } from 'react';

import classNames from 'classnames';
import { NavLink } from 'react-router-dom';
import type { NavLinkProps } from 'react-router-dom';

import { CaretDownIcon } from '@phosphor-icons/react';
import type { Icon } from '@phosphor-icons/react';

import { Badge } from '@/mastodon/components/badge';
import { Tooltip } from '@/mastodon/components/tooltip';
import { useIsLinkActive } from '@/mastodon/hooks/useIsLinkActive';

import classes from './navigation_link.module.scss';

type NavigationLinkProps = {
  icon?: Icon | React.FC<SVGProps<SVGSVGElement>>;
  badgeCount?: number;
  withDivider?: boolean;
} & (
  | ({ as?: 'button' } & React.ComponentPropsWithRef<'button'>)
  | ({ as?: 'a' } & React.ComponentPropsWithRef<'a'>)
  | ({ as?: 'link' } & NavLinkProps)
);

export const NavigationLink: React.FC<NavigationLinkProps> = ({
  as = 'link',
  icon: IconComp,
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

export type MiniNavigationLinkProps = {
  badgeType?: 'default' | 'dot';
  badgeCount?: number;
  withMenuIndicator?: boolean;
  children: ReactNode;
  icon: Icon | React.FC<SVGProps<SVGSVGElement>> | { customIcon: ReactNode };
} & (
  | ({ as?: 'button' } & React.ComponentPropsWithRef<'button'>)
  | ({ as?: 'a' } & React.ComponentPropsWithRef<'a'>)
  | ({ as?: 'link' } & NavLinkProps)
);

export const MiniNavigationLink: React.FC<MiniNavigationLinkProps> = ({
  as = 'link',
  icon: IconComp,
  badgeType = 'default',
  badgeCount,
  withMenuIndicator,
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

  const icon =
    'customIcon' in IconComp ? (
      IconComp.customIcon
    ) : (
      <IconComp size={24} weight={isActive ? 'fill' : undefined} />
    );

  const withDot = !!badgeCount && badgeType === 'dot';
  const withBadge = !!badgeCount && badgeType === 'default';

  return (
    <li>
      <Tooltip text={children} placement='top' offset={-2}>
        {({ getTooltipProps }) => (
          <Comp
            type={as === 'button' ? 'button' : undefined}
            {...getTooltipProps(otherProps)}
            className={classNames(classes.link, classes.linkMini)}
          >
            <span
              className={classNames(
                classes.icon,
                withDot && classes.iconWithDot,
              )}
            >
              {icon}
            </span>
            <span className='sr-only'>{children}</span>
            {withMenuIndicator && (
              <CaretDownIcon
                weight='fill'
                size={10}
                className={classes.menuIndicatorIcon}
              />
            )}

            {withBadge && (
              <Badge
                variant='accent'
                label={badgeCount}
                className={classes.miniBadge}
              />
            )}
          </Comp>
        )}
      </Tooltip>
    </li>
  );
};
