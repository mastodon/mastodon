import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import classNames from 'classnames';

const MissingIndicator = ({ fullPage }) => (
  <div className={classNames('regeneration-indicator', { 'regeneration-indicator--without-header': fullPage })}>
    <div className='regeneration-indicator__label'>
      <FormattedMessage id='missing_indicator.label' tagName='strong' defaultMessage='Not found' />
      <FormattedMessage id='missing_indicator.sublabel' defaultMessage='This resource could not be found' />
    </div>
  </div>
);

MissingIndicator.propTypes = {
  fullPage: PropTypes.bool,
};

export default MissingIndicator;
