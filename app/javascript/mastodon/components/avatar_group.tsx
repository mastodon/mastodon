import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { Avatar } from 'mastodon/components/avatar';
import { useAppSelector } from 'mastodon/store';
import Permalink from 'mastodon/components/permalink';

const AvatarWrapper: React.FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));

  if (!account) return null;

  return (
    <Permalink
      href={account.url}
      to={`/@${account.acct}`}
      title={`@${account.acct}`}
      data-hover-card-account={account.id}
    >
      <Avatar account={account} size={28} />
    </Permalink>
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
