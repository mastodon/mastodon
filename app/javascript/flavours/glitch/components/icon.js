//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';

//  This just renders a FontAwesome icon.
export default function Icon ({
  className,
  fullwidth,
  icon,
}) {
  const computedClass = classNames('icon', 'fa', { 'fa-fw': fullwidth }, `fa-${icon}`, className);
  return icon ? (
    <span
      aria-hidden='true'
      className={computedClass}
    />
  ) : null;
}

//  Props.
Icon.propTypes = {
  className: PropTypes.string,
  fullwidth: PropTypes.bool,
  icon: PropTypes.string,
};
