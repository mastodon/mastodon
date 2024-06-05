import { Avatar } from 'mastodon/components/avatar';
import { useAppSelector } from 'mastodon/store';
import { Link } from 'react-router-dom';

const AvatarWrapper = ({ accountId }) => {
  const account = useAppSelector(state => state.getIn(['accounts', accountId]));

  return (
    <Link to={`/@${account.get('acct')}`} title={`@${account.get('acct')}`}>
      <Avatar account={account} size={28} />
    </Link>
  );
};

export const AvatarGroup = ({ accountIds }) => (
  <div className='notification-group__avatar-group'>
    {accountIds.map(accountId => <AvatarWrapper key={accountId} accountId={accountId} />)}
  </div>
);
