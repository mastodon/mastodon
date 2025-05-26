import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';

import { LimitedAccountHint } from 'mastodon/features/account_timeline/components/limited_account_hint';
import { me } from 'mastodon/initial_state';

interface EmptyMessageProps {
  suspended: boolean;
  hidden: boolean;
  blockedBy: boolean;
  accountId?: string;
}

export const EmptyMessage: React.FC<EmptyMessageProps> = ({
  accountId,
  suspended,
  hidden,
  blockedBy,
}) => {
  const { acct } = useParams<{ acct?: string }>();
  if (!accountId) {
    return null;
  }

  let message: React.ReactNode = null;

  if (me === accountId) {
    message = (
      <FormattedMessage
        id='empty_column.account_featured.me'
        defaultMessage='You have not featured anything yet. Did you know that you can feature your hashtags you use the most, and even your friend’s accounts on your profile?'
      />
    );
  } else if (suspended) {
    message = (
      <FormattedMessage
        id='empty_column.account_suspended'
        defaultMessage='Account suspended'
      />
    );
  } else if (hidden) {
    message = <LimitedAccountHint accountId={accountId} />;
  } else if (blockedBy) {
    message = (
      <FormattedMessage
        id='empty_column.account_unavailable'
        defaultMessage='Profile unavailable'
      />
    );
  } else if (acct) {
    message = (
      <FormattedMessage
        id='empty_column.account_featured.other'
        defaultMessage='{acct} has not featured anything yet. Did you know that you can feature your hashtags you use the most, and even your friend’s accounts on your profile?'
        values={{ acct }}
      />
    );
  } else {
    message = (
      <FormattedMessage
        id='empty_column.account_featured_other.unknown'
        defaultMessage='This account has not featured anything yet.'
      />
    );
  }

  return <div className='empty-column-indicator'>{message}</div>;
};
