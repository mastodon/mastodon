import { Link } from 'react-router-dom';

import { Avatar } from 'mastodon/components/avatar';
import { useAppSelector } from 'mastodon/store';

const AvatarWrapper: React.FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));

  if (!account) return null;

  return (
    <Link to={`/@${account.acct}`} title={`@${account.acct}`}>
      <Avatar account={account} size={28} />
    </Link>
  );
};

export const AvatarGroup: React.FC<{ accountIds: string[] }> = ({
  accountIds,
}) => (
  <div className='notification-group__avatar-group'>
    {accountIds.slice(0, 7).map((accountId) => (
      <AvatarWrapper key={accountId} accountId={accountId} />
    ))}
  </div>
);
