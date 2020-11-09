import React from 'react';
import { FormattedMessage } from 'react-intl';
import illustration from 'mastodon/../images/elephant_ui_working_sub.png';

const RegenerationIndicator = () => (
  <div className='regeneration-indicator'>
    <div className='regeneration-indicator__figure'>
      <img src={illustration} alt='' />
    </div>

    <div className='regeneration-indicator__label'>
      <FormattedMessage id='regeneration_indicator.label' tagName='strong' defaultMessage='Loading&hellip;' />
      <FormattedMessage id='regeneration_indicator.sublabel' defaultMessage='Your home feed is being prepared!' />
    </div>
  </div>
);

export default RegenerationIndicator;
