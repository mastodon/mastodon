import type React from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { useAccountStatus } from '@/mastodon/hooks/useStatus';
import type { ExpandedStatusShape } from '@/mastodon/models/status';
import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import { useAppSelector } from '@/mastodon/store';

import { Avatar } from '../avatar';
import { DisplayName } from '../display_name';
import { Icon } from '../icon';
import { RelativeTimestamp } from '../relative_timestamp';

import { StatusBoostIcon } from './icons';
import classes from './prepend.module.scss';
import { statusLink } from './utils';

export const StatusPrepend: React.FC<{
  status: ExpandedStatusShape;
  reblogId?: string;
  showThread?: boolean;
}> = ({ status, showThread, reblogId }) => {
  if (!reblogId && (!showThread || !status.in_reply_to_id)) {
    return null;
  }

  return (
    <>
      {!!reblogId && <StatusPrependReblog reblogId={reblogId} />}
      {showThread &&
        !!status.in_reply_to_id &&
        !!status.in_reply_to_account_id && (
          <StatusPrependReply
            statusAccountId={status.account.id}
            replyId={status.in_reply_to_id}
            replyAccountId={status.in_reply_to_account_id}
          />
        )}
    </>
  );
};

const StatusPrependReblog: React.FC<{ reblogId: string }> = ({ reblogId }) => {
  const status = useAccountStatus(reblogId);
  if (!status) {
    return null;
  }

  const account = status.account;
  const accountLinkProps = {
    to: {
      pathname: `/@${account.acct}`,
      state: { reference: 'status' },
    },
    title: `@${account.acct}`,
    'data-id': account.id,
    'data-hover-card-account': account.id,
    'data-hover-card-reference': 'status',
  };
  return (
    <div className={classes.root}>
      <Icon icon={StatusBoostIcon} className={classes.reblogIcon} />

      <span className={classes.contents}>
        <Link {...accountLinkProps} role='presentation' tabIndex={-1}>
          <Avatar account={account} />
        </Link>
        <FormattedMessage
          id='status.reblogged_by'
          defaultMessage='{name} boosted'
          values={{
            name: (
              <Link {...accountLinkProps} className={classes.account}>
                <DisplayName variant='simple' account={account} />
              </Link>
            ),
          }}
        />
        &nbsp;&bull;
        <RelativeTimestamp timestamp={status.created_at} />
      </span>
    </div>
  );
};

const StatusPrependReply: React.FC<{
  statusAccountId: string;
  replyId: string;
  replyAccountId: string;
}> = ({ statusAccountId, replyId, replyAccountId }) => {
  const accountId = replyAccountId;
  const account = useAppSelector((state) =>
    selectPlainAccount(state, accountId),
  );

  let label: React.ReactNode;
  if (statusAccountId === replyAccountId) {
    label = (
      <FormattedMessage
        id='status.continuing_thread'
        defaultMessage='Continuing a thread'
      />
    );
  } else if (account) {
    label = (
      <FormattedMessage
        id='status.replying_to'
        defaultMessage='Replying to {name}'
        values={{
          name: <DisplayName account={account} variant='simple' />,
        }}
      />
    );
  } else {
    label = (
      <FormattedMessage
        id='status.replying_to_thread'
        defaultMessage='Replying to thread'
      />
    );
  }

  return (
    <div className={classes.root}>
      <div className={classes.replyIcon} />

      <Link to={statusLink({ id: replyId, account: accountId })}>{label}</Link>
    </div>
  );
};
