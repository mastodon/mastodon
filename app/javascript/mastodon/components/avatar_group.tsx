import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { Avatar } from 'mastodon/components/avatar';
import { useAppSelector } from 'mastodon/store';

const AvatarWrapper: React.FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));

  if (!account) return null;

  return (
    <Link
      to={`/@${account.acct}`}
      title={`@${account.acct}`}
      data-hover-card-account={account.id}
    >
      <Avatar account={account} size={28} />
    </Link>
  );
};

export const AvatarGroup: React.FC<{
  accountIds: string[];
  compact?: boolean;
}> = ({ accountIds, compact = false }) => (
  <div
    className={classNames('avatar-group', { 'avatar-group--compact': compact })}
  >
    {accountIds.map((accountId) => (
      <AvatarWrapper key={accountId} accountId={accountId} />
    ))}
  </div>
);
