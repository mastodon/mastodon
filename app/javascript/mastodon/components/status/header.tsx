import type { FC, HTMLAttributes, ReactNode } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { useIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { isStatusVisibility } from '@/mastodon/api_types/statuses';
import type { Account } from '@/mastodon/models/account';
import type { Status } from '@/mastodon/models/status';

import { Avatar } from '../avatar';
import { AvatarOverlay } from '../avatar_overlay';
import type { DisplayNameProps } from '../display_name';
import { LinkedDisplayName } from '../display_name';
import { RelativeTimestamp } from '../relative_timestamp';
import { VisibilityIcon } from '../visibility_icon';

export interface StatusHeaderProps {
  status: Status;
  account?: Account;
  avatarSize?: number;
  children?: ReactNode;
  wrapperProps?: HTMLAttributes<HTMLDivElement>;
  displayNameProps?: DisplayNameProps;
  messages: {
    edited: MessageDescriptor;
    quote_cancel: MessageDescriptor;
  };
}

export const StatusHeader: FC<StatusHeaderProps> = ({
  status,
  account,
  children,
  avatarSize = 48,
  wrapperProps,
  messages,
  displayNameProps,
}) => {
  const intl = useIntl();
  const statusAccount = status.get('account') as Account | undefined;
  const visibility = status.get('visibility') as string;
  const editedAt = status.get('edited_at') as string;
  const AccountComponent = account ? AvatarOverlay : Avatar;

  return (
    <div {...wrapperProps} className='status__info'>
      <Link
        to={`/@${statusAccount?.acct}/${status.get('id') as string}`}
        className='status__relative-time'
      >
        {isStatusVisibility(visibility) && (
          <span className='status__visibility-icon'>
            <VisibilityIcon visibility={visibility} />
          </span>
        )}
        <RelativeTimestamp timestamp={status.get('created_at') as string} />
        {editedAt && (
          <abbr
            title={intl.formatMessage(messages.edited, {
              date: intl.formatDate(editedAt, {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
              }),
            })}
          >
            {' '}
            *
          </abbr>
        )}
      </Link>

      <LinkedDisplayName
        displayProps={{ ...displayNameProps, account: statusAccount }}
        className='status__display-name'
      >
        <div className='status__avatar'>
          <AccountComponent
            account={statusAccount}
            friend={account}
            size={avatarSize}
          />
        </div>
      </LinkedDisplayName>

      {children}
    </div>
  );
};
