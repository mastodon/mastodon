import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { ArrowsClockwiseIcon } from '@phosphor-icons/react';

import type { ExpandedStatusShape } from '@/mastodon/models/status';

import { Avatar } from '../avatar';
import { DisplayName } from '../display_name';
import { Icon } from '../icon';
import { RelativeTimestamp } from '../relative_timestamp';
import { StatusThreadLabel } from '../status_thread_label';

import classes from './styles.module.scss';

export const StatusPrepend: React.FC<{
  status: ExpandedStatusShape;
  showThread?: boolean;
  isReblog?: boolean;
}> = ({ status, showThread, isReblog }) => {
  if (!isReblog && (!showThread || !status.in_reply_to_id)) {
    return null;
  }

  let reply: React.ReactNode = null;

  if (showThread && status.in_reply_to_account_id) {
    reply = (
      <div className={classes.prepend}>
        <StatusThreadLabel
          accountId={status.account.id}
          inReplyToAccountId={status.in_reply_to_account_id}
        />
      </div>
    );
  }

  return (
    <>
      {isReblog && <StatusPrependReblog status={status} />}
      {reply}
    </>
  );
};

const StatusPrependReblog: React.FC<{ status: ExpandedStatusShape }> = ({
  status,
}) => {
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
    <div className={classes.prepend}>
      <Icon icon={ArrowsClockwiseIcon} className={classes.prependIcon} />

      <span className={classes.prependContents}>
        <Link {...accountLinkProps} role='presentation' tabIndex={-1}>
          <Avatar account={account} />
        </Link>
        <FormattedMessage
          id='status.reblogged_by'
          defaultMessage='{name} boosted'
          values={{
            name: (
              <Link {...accountLinkProps}>
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
