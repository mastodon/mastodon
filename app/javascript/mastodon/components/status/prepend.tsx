import { FormattedMessage } from 'react-intl';

import type { ExpandedStatusShape } from '@/mastodon/models/status';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';

import { LinkedDisplayName } from '../display_name';
import { Icon } from '../icon';
import { StatusThreadLabel } from '../status_thread_label';

export const StatusPrepend: React.FC<{
  status: ExpandedStatusShape;
  showThread?: boolean;
  isReblog?: boolean;
}> = ({ status, showThread, isReblog }) => {
  if (isReblog) {
    return (
      <div className='status__prepend'>
        <div className='status__prepend__icon'>
          <Icon id='retweet' icon={RepeatIcon} />
        </div>
        <FormattedMessage
          id='status.reblogged_by'
          defaultMessage='{name} boosted'
          values={{
            name: (
              <LinkedDisplayName
                displayProps={{
                  account: status.account,
                  variant: 'simple',
                }}
                className='status__display-name muted'
              />
            ),
          }}
          tagName='span'
        />
      </div>
    );
  }

  if (status.visibility === 'direct') {
    return (
      <div className='status__prepend'>
        <div className='status__prepend__icon'>
          <Icon id='at' icon={AlternateEmailIcon} />
        </div>
        <FormattedMessage
          id='status.direct_indicator'
          defaultMessage='Private mention'
          tagName='span'
        />
      </div>
    );
  }

  if (showThread && status.in_reply_to_account_id) {
    return (
      <StatusThreadLabel
        accountId={status.account.id}
        inReplyToAccountId={status.in_reply_to_account_id}
      />
    );
  }

  return null;
};
