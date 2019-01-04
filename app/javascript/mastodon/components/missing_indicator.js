import React from 'react';
import { FormattedMessage } from 'react-intl';

const MissingIndicator = () => (
  <div className='regeneration-indicator missing-indicator'>
    <div>
      <div className='regeneration-indicator__figure' />

      <div className='regeneration-indicator__label'>
        <FormattedMessage id='missing_indicator.label' tagName='strong' defaultMessage='Not found' />
        <FormattedMessage id='missing_indicator.sublabel' defaultMessage='This resource could not be found' />
      </div>
    </div>
  </div>
);

export default MissingIndicator;
