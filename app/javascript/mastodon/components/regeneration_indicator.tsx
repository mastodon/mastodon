import { FormattedMessage } from 'react-intl';

import { GIF } from './gif';

export const RegenerationIndicator: React.FC = () => (
  <div className='regeneration-indicator'>
    <GIF
      src='/loading.gif'
      staticSrc='/loading.png'
      className='regeneration-indicator__figure'
    />

    <div className='regeneration-indicator__label'>
      <strong>
        <FormattedMessage
          id='regeneration_indicator.preparing_your_home_feed'
          defaultMessage='Preparing your home feed…'
        />
      </strong>
      <FormattedMessage
        id='regeneration_indicator.please_stand_by'
        defaultMessage='Please stand by.'
      />
    </div>
  </div>
);
