import type { FC } from 'react';

import { Link } from 'react-router-dom';

import { RelativeTimestamp } from '@/mastodon/components/relative_timestamp';
import type { StatusHeaderProps } from '@/mastodon/components/status/header';
import {
  StatusDisplayName,
  StatusEditedAt,
  StatusVisibility,
} from '@/mastodon/components/status/header';
import type { Account } from '@/mastodon/models/account';

export const AccountStatusHeader: FC<StatusHeaderProps> = ({
  status,
  account,
  children,
  avatarSize = 48,
  wrapperProps,
  onHeaderClick,
}) => {
  const statusAccount = status.get('account') as Account | undefined;
  const editedAt = status.get('edited_at') as string;

  return (
    /* eslint-disable jsx-a11y/no-static-element-interactions, jsx-a11y/click-events-have-key-events */
    <div
      onClick={onHeaderClick}
      onAuxClick={onHeaderClick}
      {...wrapperProps}
      className='status__info'
      /* eslint-enable jsx-a11y/no-static-element-interactions, jsx-a11y/click-events-have-key-events */
    >
      <Link
        to={`/@${statusAccount?.acct}/${status.get('id') as string}`}
        className='status__relative-time'
      >
        <StatusVisibility visibility={status.get('visibility')} />
        <RelativeTimestamp timestamp={status.get('created_at') as string} />
        {editedAt && <StatusEditedAt editedAt={editedAt} />}
      </Link>

      <StatusDisplayName
        statusAccount={statusAccount}
        friendAccount={account}
        avatarSize={avatarSize}
      />

      {children}
    </div>
  );
};
