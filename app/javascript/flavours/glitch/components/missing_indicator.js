import React from 'react';
import { FormattedMessage } from 'react-intl';

const MissingIndicator = () => (
  <div className='missing-indicator'>
    <div>
      <FormattedMessage id='missing_indicator.label' defaultMessage='Not found' />
    </div>
  </div>
);

export default MissingIndicator;
