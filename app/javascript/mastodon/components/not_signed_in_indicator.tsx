import React from 'react';
import { FormattedMessage } from 'react-intl';

export const NotSignedInIndicator: React.FC = () => (
  <div className='scrollable scrollable--flex'>
    <div className='empty-column-indicator'>
      <FormattedMessage
        id='not_signed_in_indicator.not_signed_in'
        defaultMessage='You need to sign in to access this resource.'
      />
    </div>
  </div>
);
