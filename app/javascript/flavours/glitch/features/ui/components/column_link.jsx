import React from 'react';
import PropTypes from 'prop-types';
import { NavLink } from 'react-router-dom';
import Icon from 'flavours/glitch/components/icon';
import classNames from 'classnames';

const ColumnLink = ({ icon, text, to, onClick, href, method, badge, transparent, ...other }) => {
  const className = classNames('column-link', { 'column-link--transparent': transparent });
  const badgeElement = typeof badge !== 'undefined' ? <span className='column-link__badge'>{badge}</span> : null;
  const iconElement = typeof icon === 'string' ? <Icon id={icon} fixedWidth className='column-link__icon' /> : icon;

  if (href) {
    return (
      <a href={href} className={className} data-method={method} title={text} {...other}>
        {iconElement}
        <span>{text}</span>
        {badgeElement}
      </a>
    );
  } else if (to) {
    return (
      <NavLink to={to} className={className} title={text} {...other}>
        {iconElement}
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
  text: PropTypes.string.isRequired,
  to: PropTypes.string,
  onClick: PropTypes.func,
  href: PropTypes.string,
  method: PropTypes.string,
  badge: PropTypes.node,
  transparent: PropTypes.bool,
};

export default ColumnLink;
