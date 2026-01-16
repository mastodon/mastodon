import type { FC } from 'react';

import { useIntl } from 'react-intl';

import { NavLink } from 'react-router-dom';

import {
  FollowersCounter,
  FollowingCounter,
  StatusesCounter,
} from '@/mastodon/components/counters';
import { ShortNumber } from '@/mastodon/components/short_number';
import { useAccount } from '@/mastodon/hooks/useAccount';

export const AccountLinks: FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const account = useAccount(accountId);

  if (!account) {
    return null;
  }

  return (
    <div className='account__header__extra__links'>
      <NavLink
        to={`/@${account.acct}`}
        title={intl.formatNumber(account.statuses_count)}
      >
        <ShortNumber
          value={account.statuses_count}
          renderer={StatusesCounter}
        />
      </NavLink>

      <NavLink
        exact
        to={`/@${account.acct}/following`}
        title={intl.formatNumber(account.following_count)}
      >
        <ShortNumber
          value={account.following_count}
          renderer={FollowingCounter}
        />
      </NavLink>

      <NavLink
        exact
        to={`/@${account.acct}/followers`}
        title={intl.formatNumber(account.followers_count)}
      >
        <ShortNumber
          value={account.followers_count}
          renderer={FollowersCounter}
        />
      </NavLink>
    </div>
  );
};
