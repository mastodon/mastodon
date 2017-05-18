import React from 'react';
import PropTypes from 'prop-types';
import Link from 'react-router/lib/Link';

const ColumnLink = ({ icon, text, to, href, method, hideOnMobile }) => {
  if (href) {
    return (
      <a href={href} className={`column-link ${hideOnMobile ? 'hidden-on-mobile' : ''}`} data-method={method}>
        <i className={`fa fa-fw fa-${icon} column-link__icon`} />
        {text}
      </a>
    );
  } else {
    return (
      <Link to={to} className={`column-link ${hideOnMobile ? 'hidden-on-mobile' : ''}`}>
        <i className={`fa fa-fw fa-${icon} column-link__icon`} />
        {text}
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
  hideOnMobile: PropTypes.bool
};

export default ColumnLink;
