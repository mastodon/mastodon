import { useId } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { PushPinIcon } from '@phosphor-icons/react';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import type { AccountStatusShape } from '@/mastodon/models/status';

import { Avatar } from '../avatar';
import { Badge } from '../badge';
import { DisplayName } from '../display_name';
import { useAccountHandle } from '../display_name/default';
import { Icon } from '../icon';
import { RelativeTimestamp } from '../relative_timestamp';
import { Skeleton } from '../skeleton';

import classes from './header.module.scss';
import { accountStatusLinkProps, statusLink } from './utils';

interface StatusHeaderProps {
  status: Pick<
    AccountStatusShape,
    'id' | 'account' | 'created_at' | 'visibility' | 'mentions'
  >;
  className?: string;
  featured?: boolean;
}

export const StatusHeader: React.FC<StatusHeaderProps> = ({
  status,
  className,
  featured,
}) => {
  const account = status.account;
  const handle = useAccountHandle(account);

  const handleId = useId();
  const accountLinkProps = accountStatusLinkProps(account);

  return (
    <header className={classNames(className, classes.root)}>
      <Link
        {...accountLinkProps}
        role='presentation'
        tabIndex={-1}
        className={classes.avatar}
      >
        <Avatar account={account} size={null} />
      </Link>

      <div className={classes.accountWrapper}>
        <StatusHeaderAuthors status={status} handleId={handleId} />

        <p className={classes.handle}>
          <Link
            {...accountLinkProps}
            role='presentation'
            tabIndex={-1}
            id={handleId}
            data-main-account-link='true'
          >
            {handle ?? <Skeleton width='7ch' />}
          </Link>
        </p>
      </div>

      {featured && (
        <Badge
          className={classes.pinnedBadge}
          icon={<Icon id='pinned' icon={PushPinIcon} />}
          label={
            <FormattedMessage
              id='account.timeline.pinned'
              defaultMessage='Pinned'
            />
          }
        />
      )}
    </header>
  );
};

export const StatusHeaderAuthors: React.FC<
  Pick<StatusHeaderProps, 'status'> & { className?: string; handleId?: string }
> = ({ status, className, handleId }) => {
  const currentAccountId = useCurrentAccountId();
  const firstMentionAccount = useAccount(
    status.mentions.find(({ id }) => id !== currentAccountId)?.id,
  );

  const { account } = status;

  let displayName = (
    <Link
      {...accountStatusLinkProps(account)}
      className={classes.nameLink}
      aria-describedby={handleId}
      data-main-account-link='true'
    >
      <DisplayName account={account} variant='noDomain' />
    </Link>
  );
  if (status.visibility === 'private') {
    displayName = (
      <FormattedMessage
        id='status.header.to_followers'
        defaultMessage='{author} to Followers {count, plural, =0 {} one {+ # other} other {+ # others}}'
        description='Count is # of other people mentioned in the post'
        values={{ author: displayName, count: status.mentions.length }}
      />
    );
  } else if (status.visibility === 'direct' && status.mentions.length > 0) {
    if (status.account.id === currentAccountId && firstMentionAccount) {
      displayName = (
        <FormattedMessage
          id='status.header.message_from_me'
          defaultMessage='You to {name} {count, plural, =0 {} one {+ # other} other {+ # others}}'
          description='DisplayName is the author, count is # of other people mentioned in the post'
          values={{
            name: (
              <Link
                {...accountStatusLinkProps(firstMentionAccount)}
                className={classes.nameLink}
              >
                <DisplayName account={firstMentionAccount} variant='simple' />
              </Link>
            ),
            // Minus two, as we're removing the current user as well.
            count: Math.max(status.mentions.length - 2, 0),
          }}
        />
      );
    } else {
      displayName = (
        <FormattedMessage
          id='status.header.message_to_me'
          defaultMessage='{author} to You {count, plural, =0 {} one {+ # other} other {+ # others}}'
          description='DisplayName is the author, count is # of other people mentioned in the post'
          values={{ author: displayName, count: status.mentions.length - 1 }}
        />
      );
    }
  }

  return (
    <p className={classNames(className, classes.name)}>
      {displayName}
      {/* Wrap the bullet with a span to not have the whitespace collapse */}
      <span aria-hidden='true'>&bull;</span>
      <Link
        to={{
          pathname: statusLink(status),
          state: { reference: 'status' },
        }}
        className={classes.date}
      >
        <RelativeTimestamp timestamp={status.created_at} />
      </Link>
    </p>
  );
};
