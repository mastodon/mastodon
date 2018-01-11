import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

const ColumnLink = ({ icon, text, to, href, method, badge }) => {
  if (href) {
    return (
      <a href={href} className='column-link' data-method={method}>
        <i className={`fa fa-fw fa-${icon} column-link__icon`} />
        {text}
        {badge}
      </a>
    );
  } else {
    return (
      <Link to={to} className='column-link'>
        <i className={`fa fa-fw fa-${icon} column-link__icon`} />
        {text}
        {badge}
      </Link>
    );
  }
};

ColumnLink.propTypes = {
  icon: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  to: PropTypes.string,
  href: PropTypes.string,
  method: PropTypes.string,
  badge: PropTypes.object,
};

export default ColumnLink;
