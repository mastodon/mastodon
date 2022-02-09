import React from 'react';
import { FormattedMessage } from 'react-intl';

const LoadingIndicator = () => (
  <div className='loading-indicator'>
    <div className='loading-indicator__figure' />
    <FormattedMessage id='loading_indicator.label' defaultMessage='Loading...' />
  </div>
);

export default LoadingIndicator;
