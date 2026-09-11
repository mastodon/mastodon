import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { criticalUpdatesPending } from '@/mastodon/initial_state';

export const CriticalUpdateBanner: FC = () => {
  if (!criticalUpdatesPending) {
    return null;
  }
  return (
    <div className='warning-banner'>
      <div className='warning-banner__message'>
        <FormattedMessage
          id='home.pending_critical_update.title'
          defaultMessage='Critical security update available!'
          tagName='h1'
        />
        <p>
          <FormattedMessage
            id='home.pending_critical_update.body'
            defaultMessage='Please update your Mastodon server as soon as possible!'
          />{' '}
          <a href='/admin/software_updates'>
            <FormattedMessage
              id='home.pending_critical_update.link'
              defaultMessage='See updates'
            />
          </a>
        </p>
      </div>
    </div>
  );
};
