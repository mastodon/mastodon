import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import illustration from 'flavours/glitch/images/elephant_ui_disappointed.svg';
import classNames from 'classnames';
import { Helmet } from 'react-helmet';

const MissingIndicator = ({ fullPage }) => (
  <div className={classNames('regeneration-indicator', { 'regeneration-indicator--without-header': fullPage })}>
    <div className='regeneration-indicator__figure'>
      <img src={illustration} alt='' />
    </div>

    <div className='regeneration-indicator__label'>
      <FormattedMessage id='missing_indicator.label' tagName='strong' defaultMessage='Not found' />
      <FormattedMessage id='missing_indicator.sublabel' defaultMessage='This resource could not be found' />
    </div>

    <Helmet>
      <meta name='robots' content='noindex' />
    </Helmet>
  </div>
);

MissingIndicator.propTypes = {
  fullPage: PropTypes.bool,
};

export default MissingIndicator;
