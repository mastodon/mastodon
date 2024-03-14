import PropTypes from 'prop-types';

import classNames from 'classnames';
import { useRouteMatch, NavLink } from 'react-router-dom';

import { Icon }  from 'flavours/glitch/components/icon';

const ColumnLink = ({ icon, activeIcon, iconComponent, activeIconComponent, text, to, onClick, href, method, badge, transparent, ...other }) => {
  const match = useRouteMatch(to);
  const className = classNames('column-link', { 'column-link--transparent': transparent });
  const badgeElement = typeof badge !== 'undefined' ? <span className='column-link__badge'>{badge}</span> : null;
  const iconElement = (typeof icon === 'string' || iconComponent) ? <Icon id={icon} icon={iconComponent} className='column-link__icon' /> : icon;
  const activeIconElement = activeIcon ?? (activeIconComponent ? <Icon id={icon} icon={activeIconComponent} className='column-link__icon' /> : iconElement);
  const active = match?.isExact;

  if (href) {
    return (
      <a href={href} className={className} data-method={method} title={text} {...other}>
        {active ? activeIconElement : iconElement}
        <span>{text}</span>
        {badgeElement}
      </a>
    );
  } else if (to) {
    return (
      <NavLink to={to} className={className} title={text} exact {...other}>
        {active ? activeIconElement : iconElement}
        <span>{text}</span>
        {badgeElement}
      </NavLink>
    );
  } else {
    const handleOnClick = (e) => {
      e.preventDefault();
      e.stopPropagation();
      return onClick(e);
    };
    return (
      // eslint-disable-next-line jsx-a11y/anchor-is-valid -- intentional to have the same look and feel as other menu items
      <a href='#' onClick={onClick && handleOnClick} className={className} title={text} {...other} tabIndex={0}>
        {iconElement}
        <span>{text}</span>
        {badgeElement}
      </a>
    );
  }
};

ColumnLink.propTypes = {
  icon: PropTypes.oneOfType([PropTypes.string, PropTypes.node]).isRequired,
  iconComponent: PropTypes.func,
  activeIcon: PropTypes.node,
  activeIconComponent: PropTypes.func,
  text: PropTypes.string.isRequired,
  to: PropTypes.string,
  onClick: PropTypes.func,
  href: PropTypes.string,
  method: PropTypes.string,
  badge: PropTypes.node,
  transparent: PropTypes.bool,
};

export default ColumnLink;
