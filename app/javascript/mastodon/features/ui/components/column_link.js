import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

const ColumnLink = ({ icon, text, to, href, rel, target, method }) => {
  if (href) {
    return (
      <a href={href} rel={rel} target={target} className='column-link' data-method={method}>
        <i className={`fa fa-fw fa-${icon} column-link__icon`} />
        {text}
      </a>
    );
  } else {
    return (
      <Link to={to} className='column-link'>
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
  rel: PropTypes.string,
  target: PropTypes.string,
  method: PropTypes.string,
};

export default ColumnLink;
