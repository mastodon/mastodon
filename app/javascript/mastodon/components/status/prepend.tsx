import type React from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { ArrowsClockwiseIcon } from '@phosphor-icons/react';

import { useAccountStatus } from '@/mastodon/hooks/useStatus';
import type { ExpandedStatusShape } from '@/mastodon/models/status';

import { Avatar } from '../avatar';
import { DisplayName } from '../display_name';
import { EmojiHTML } from '../emoji/html';
import { Icon } from '../icon';
import { RelativeTimestamp } from '../relative_timestamp';

import { onStatusLinksDisabled } from './hooks';
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
      {showThread && !!status.in_reply_to_id && (
        <StatusPrependReply replyId={status.in_reply_to_id} />
      )}
    </>
  );
};

const StatusPrependReblog: React.FC<{ reblogId: string }> = ({ reblogId }) => {
  const status = useAccountStatus(reblogId, true);
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
      <Icon icon={ArrowsClockwiseIcon} className={classes.reblogIcon} />

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

const StatusPrependReply: React.FC<{ replyId: string }> = ({ replyId }) => {
  const status = useAccountStatus(replyId, true);

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

  const language = status.translation?.language ?? status.language;

  return (
    <div className={classes.root}>
      <div className={classes.replyIcon} />

      <div>
        <span className={classes.contents}>
          <Link {...accountLinkProps} role='presentation' tabIndex={-1}>
            <Avatar account={account} />
          </Link>
          <Link {...accountLinkProps} className={classes.account}>
            <DisplayName variant='simple' account={account} />
          </Link>
          &bull;
          <Link to={statusLink(status)}>
            <RelativeTimestamp timestamp={status.created_at} />
          </Link>
        </span>

        <Link to={statusLink(status)} className={classes.text}>
          <EmojiHTML
            as='blockquote'
            lang={language}
            htmlString={status.translation?.contentHtml ?? status.contentHtml}
            extraEmojis={status.emojis}
            onElement={onStatusLinksDisabled}
          />
        </Link>
      </div>
    </div>
  );
};
