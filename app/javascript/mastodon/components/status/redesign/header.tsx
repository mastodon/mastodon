import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { AccountStatusShape } from '@/mastodon/models/status';

import { Avatar } from '../../avatar';
import { DisplayName } from '../../display_name';
import { useAccountHandle } from '../../display_name/default';
import { RelativeTimestamp } from '../../relative_timestamp';
import { Skeleton } from '../../skeleton';
import { statusLink } from '../utils';

import classes from './styles.module.scss';

interface StatusRedesignHeaderProps {
  status: Pick<AccountStatusShape, 'id' | 'account' | 'created_at'>;
  children?: React.ReactNode;
  className?: string;
  avatarSize?: number;
}

export const StatusRedesignHeader: React.FC<StatusRedesignHeaderProps> = ({
  status,
  children,
  className,
  avatarSize = 40,
}) => {
  const account = status.account;
  const handle = useAccountHandle(account);

  const linkProps = {
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
    <header className={classNames(className, classes.header)}>
      <Link {...linkProps}>
        <Avatar account={account} size={avatarSize} />
      </Link>

      <div className={classes.headerNameWrapper}>
        <p className={classes.headerName}>
          <Link {...linkProps} className={classes.headerNameLink}>
            <DisplayName account={account} variant='noDomain' />
          </Link>
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
          <Link {...linkProps}>{handle ?? <Skeleton width='7ch' />}</Link>
        </p>
      </div>

      {children}
    </header>
  );
};
