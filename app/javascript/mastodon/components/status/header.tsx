import { useId } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { AccountStatusShape } from '@/mastodon/models/status';

import { Avatar } from '../avatar';
import { DisplayName } from '../display_name';
import { useAccountHandle } from '../display_name/default';
import { RelativeTimestamp } from '../relative_timestamp';
import { Skeleton } from '../skeleton';

import classes from './header.module.scss';
import { statusLink } from './utils';

interface StatusRedesignHeaderProps {
  status: Pick<
    AccountStatusShape,
    'id' | 'account' | 'created_at' | 'visibility' | 'mentions'
  >;
  children?: React.ReactNode;
  className?: string;
}

export const StatusRedesignHeader: React.FC<StatusRedesignHeaderProps> = ({
  status,
  children,
  className,
}) => {
  const account = status.account;
  const handle = useAccountHandle(account);

  const handleId = useId();
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

  let displayName = (
    <Link
      {...accountLinkProps}
      className={classes.headerNameLink}
      aria-describedby={handleId}
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
        tagName='span'
        values={{ author: displayName, count: status.mentions.length }}
      />
    );
  } else if (status.visibility === 'direct') {
    displayName = (
      <FormattedMessage
        id='status.header.message_to_me'
        defaultMessage='{author} to You {count, plural, =0 {} one {+ # other} other {+ # others}}'
        description='DisplayName is the author, count is # of other people mentioned in the post'
        tagName='span'
        values={{ author: displayName, count: status.mentions.length - 1 }}
      />
    );
  }

  return (
    <header className={classNames(className, classes.header)}>
      <Link
        {...accountLinkProps}
        role='presentation'
        tabIndex={-1}
        className={classes.headerAvatar}
      >
        <Avatar account={account} size={null} />
      </Link>

      <div>
        <p className={classes.headerName}>
          {displayName}
          &bull;
          <Link
            to={{
              pathname: statusLink(status),
              state: { reference: 'status' },
            }}
          >
            <RelativeTimestamp timestamp={status.created_at} />
          </Link>
        </p>

        <p className={classes.headerHandle}>
          <Link
            {...accountLinkProps}
            role='presentation'
            tabIndex={-1}
            id={handleId}
          >
            {handle ?? <Skeleton width='7ch' />}
          </Link>
        </p>
      </div>

      {children}
    </header>
  );
};
