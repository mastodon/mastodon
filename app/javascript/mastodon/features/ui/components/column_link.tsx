import classNames from 'classnames';
import { matchPath, useLocation, NavLink } from 'react-router-dom';

import { Icon } from 'mastodon/components/icon';
import type { IconProp } from 'mastodon/components/icon';
import type { MastodonLocationDescriptor } from 'mastodon/components/router';

export const ColumnLink: React.FC<{
  icon: React.ReactNode;
  iconComponent?: IconProp;
  activeIcon?: React.ReactNode;
  activeIconComponent?: IconProp;
  text: string;
  to?: MastodonLocationDescriptor;
  activePath?: string | string[];
  href?: string;
  method?: string;
  badge?: React.ReactNode;
  transparent?: boolean;
  exact?: boolean;
  className?: string;
  id?: string;
}> = ({
  icon,
  activeIcon,
  iconComponent,
  activeIconComponent,
  text,
  to,
  activePath,
  href,
  method,
  badge,
  transparent,
  exact,
  ...other
}) => {
  const location = useLocation();
  const targetPath = typeof to === 'string' ? to : to?.pathname;
  const match = targetPath
    ? matchPath(location.pathname, { path: activePath ?? targetPath, exact })
    : null;
  const active = !!match;
  const className = classNames('column-link', {
    'column-link--transparent': transparent,
    active,
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
  if (href) {
    return (
      <a href={href} className={className} data-method={method} {...other}>
        {active ? activeIconElement : iconElement}
        <span>{text}</span>
        {badgeElement}
      </a>
    );
  } else if (to) {
    return (
      <NavLink to={to} className={className} exact={exact} {...other}>
        {active ? activeIconElement : iconElement}
        <span>{text}</span>
        {badgeElement}
      </NavLink>
    );
  } else {
    return null;
  }
};
