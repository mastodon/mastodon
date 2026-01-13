import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { DisplayName } from '@/mastodon/components/display_name';
import { AvatarOverlay } from 'mastodon/components/avatar_overlay';
import { useAppSelector } from 'mastodon/store';

export const MovedNote: React.FC<{
  accountId: string;
  targetAccountId: string;
}> = ({ accountId, targetAccountId }) => {
  const from = useAppSelector((state) => state.accounts.get(accountId));
  const to = useAppSelector((state) => state.accounts.get(targetAccountId));

  return (
    <div className='moved-account-banner'>
      <div className='moved-account-banner__message'>
        <FormattedMessage
          id='account.moved_to'
          defaultMessage='{name} has indicated that their new account is now:'
          values={{
            name: <DisplayName account={from} variant='simple' />,
          }}
        />
      </div>

      <div className='moved-account-banner__action'>
        <Link to={`/@${to?.acct}`} className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'>
            <AvatarOverlay account={to} friend={from} />
          </div>
          <DisplayName account={to} />
        </Link>

        <Link to={`/@${to?.acct}`} className='button'>
          <FormattedMessage
            id='account.go_to_profile'
            defaultMessage='Go to profile'
          />
        </Link>
      </div>
    </div>
  );
};
