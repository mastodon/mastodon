import { FormattedMessage } from 'react-intl';

import { LimitedAccountHint } from 'mastodon/features/account_timeline/components/limited_account_hint';

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
  if (!accountId) {
    return null;
  }

  let message: React.ReactNode = null;

  if (suspended) {
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
  } else {
    message = (
      <FormattedMessage
        id='empty_column.account_featured'
        defaultMessage='This list is empty'
      />
    );
  }

  return <div className='empty-column-indicator'>{message}</div>;
};
