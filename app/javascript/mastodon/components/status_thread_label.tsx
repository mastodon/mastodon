import { FormattedMessage } from 'react-intl';

import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import { Icon } from 'mastodon/components/icon';
import { DisplayedName } from 'mastodon/features/notifications_v2/components/displayed_name';
import { useAppSelector } from 'mastodon/store';

export const StatusThreadLabel: React.FC<{
  accountId: string;
  inReplyToAccountId: string;
}> = ({ accountId, inReplyToAccountId }) => {
  const inReplyToAccount = useAppSelector((state) =>
    state.accounts.get(inReplyToAccountId),
  );

  let label;

  if (accountId === inReplyToAccountId) {
    label = (
      <FormattedMessage
        id='status.continued_thread'
        defaultMessage='Continued thread'
      />
    );
  } else if (inReplyToAccount) {
    label = (
      <FormattedMessage
        id='status.replied_to'
        defaultMessage='Replied to {name}'
        values={{ name: <DisplayedName accountIds={[inReplyToAccountId]} /> }}
      />
    );
  } else {
    label = (
      <FormattedMessage
        id='status.replied_in_thread'
        defaultMessage='Replied in thread'
      />
    );
  }

  return (
    <div className='status__prepend'>
      <div className='status__prepend__icon'>
        <Icon id='reply' icon={ReplyIcon} />
      </div>
      {label}
    </div>
  );
};
