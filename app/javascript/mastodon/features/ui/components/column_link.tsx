import classNames from 'classnames';
// import { useRouteMatch, NavLink } from 'react-router-dom';

import type { LinkProps } from '@tanstack/react-router';
import { Link } from '@tanstack/react-router';

import { Icon } from 'mastodon/components/icon';
import type { IconProp } from 'mastodon/components/icon';

export const ColumnLink: React.FC<{
  icon: React.ReactNode;
  iconComponent?: IconProp;
  activeIcon?: React.ReactNode;
  activeIconComponent?: IconProp;
  isActive?: (match: unknown, location: { pathname: string }) => boolean;
  text: string;
  to?: string;
  href?: string;
  method?: string;
  badge?: React.ReactNode;
  transparent?: boolean;
  className?: string;
  id?: string;
  tanstackTo?: LinkProps['to'];
}> = ({
  icon,
  activeIcon,
  iconComponent,
  activeIconComponent,
  text,
  to,
  href,
  method,
  badge,
  transparent,
  tanstackTo,
  ...other
}) => {
  // const match = useRouteMatch(to ?? '');
  const className = classNames('column-link', {
    'column-link--transparent': transparent,
  });
  const badgeElement =
    typeof badge !== 'undefined' ? (
      <span className='column-link__badge'>{badge}</span>
    ) : null;
  const iconElement = iconComponent ? (
    <Icon
      id={typeof icon === 'string' ? icon : ''}
      icon={iconComponent}
      className='column-link__icon'
    />
  ) : (
    icon
  );
  const activeIconElement =
    activeIcon ??
    (activeIconComponent ? (
      <Icon
        id={typeof icon === 'string' ? icon : ''}
        icon={activeIconComponent}
        className='column-link__icon'
      />
    ) : (
      iconElement
    ));
  const active = false; // !!match;

  if (tanstackTo) {
    return (
      <Link
        to={tanstackTo}
        className={className}
        data-method={method}
        {...other}
      >
        {({ isActive }) => {
          return (
            <>
              {isActive ? activeIconElement : iconElement}
              <span>{text}</span>
              {badgeElement}
            </>
          );
        }}
      </Link>
    );
  } else if (href) {
    return (
      <a href={href} className={className} data-method={method} {...other}>
        {active ? activeIconElement : iconElement}
        <span>{text}</span>
        {badgeElement}
      </a>
    );
  } else if (to) {
    return (
      <a href={to} className={className} {...other}>
        {active ? activeIconElement : iconElement}
        <span>{text}</span>
        {badgeElement}
      </a>
    );
  } else {
    return null;
  }
};
