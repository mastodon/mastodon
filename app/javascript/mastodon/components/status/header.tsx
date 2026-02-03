import type { FC, HTMLAttributes, MouseEventHandler } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { useIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { isStatusVisibility } from '@/mastodon/api_types/statuses';
import type { Account } from '@/mastodon/models/account';
import type { Status } from '@/mastodon/models/status';
import CancelFillIcon from '@/material-icons/400-24px/cancel-fill.svg?react';

import { Avatar } from '../avatar';
import { AvatarOverlay } from '../avatar_overlay';
import { LinkedDisplayName } from '../display_name';
import { IconButton } from '../icon_button';
import { RelativeTimestamp } from '../relative_timestamp';
import { VisibilityIcon } from '../visibility_icon';

interface StatusHeaderProps {
  status: Status;
  account?: Account;
  avatarSize?: number;
  onQuoteCancel?: MouseEventHandler;
  wrapperProps?: HTMLAttributes<HTMLDivElement>;
  messages: {
    edited: MessageDescriptor;
    quote_cancel: MessageDescriptor;
  };
}

export const StatusHeader: FC<StatusHeaderProps> = ({
  status,
  account,
  avatarSize = 48,
  onQuoteCancel,
  wrapperProps,
  messages,
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
        displayProps={{ account: statusAccount }}
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

      {!!onQuoteCancel && (
        <IconButton
          onClick={onQuoteCancel}
          className='status__quote-cancel'
          title={intl.formatMessage(messages.quote_cancel)}
          icon='cancel-fill'
          iconComponent={CancelFillIcon}
        />
      )}
    </div>
  );
};
