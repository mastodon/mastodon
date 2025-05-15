import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { fetchAccountsFamiliarFollowers } from '@/mastodon/actions/accounts_familiar_followers';
import { Avatar } from '@/mastodon/components/avatar';
import { AvatarGroup } from '@/mastodon/components/avatar_group';
import type { Account } from '@/mastodon/models/account';
import { getAccountFamiliarFollowers } from '@/mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const AccountLink: React.FC<{ account?: Account }> = ({ account }) => {
  if (!account) {
    return null;
  }

  return (
    <Link
      to={`/@${account.acct}`}
      data-hover-card-account={account.id}
      dangerouslySetInnerHTML={{ __html: account.display_name_html }}
    />
  );
};

const FamiliarFollowersReadout: React.FC<{ familiarFollowers: Account[] }> = ({
  familiarFollowers,
}) => {
  const messageData = {
    name1: <AccountLink account={familiarFollowers.at(0)} />,
    name2: <AccountLink account={familiarFollowers.at(1)} />,
    othersCount: familiarFollowers.length - 2,
  };

  if (familiarFollowers.length === 1) {
    return (
      <FormattedMessage
        id='account.familiar_followers_one'
        defaultMessage='Followed by {name1}'
        values={messageData}
      />
    );
  } else if (familiarFollowers.length === 2) {
    return (
      <FormattedMessage
        id='account.familiar_followers_two'
        defaultMessage='Followed by {name1} and {name2}'
        values={messageData}
      />
    );
  } else {
    return (
      <FormattedMessage
        id='account.familiar_followers_many'
        defaultMessage='Followed by {name1}, {name2}, and {othersCount, plural, one {one other you know} other {# others you know}}'
        values={messageData}
      />
    );
  }
};

export const FamiliarFollowers: React.FC<{ accountId: string }> = ({
  accountId,
}) => {
  const dispatch = useAppDispatch();
  const familiarFollowers = useAppSelector((state) =>
    getAccountFamiliarFollowers(state, accountId),
  );

  const hasNoData = familiarFollowers === null;

  useEffect(() => {
    if (hasNoData) {
      void dispatch(fetchAccountsFamiliarFollowers({ id: accountId }));
    }
  }, [dispatch, accountId, hasNoData]);

  if (hasNoData || familiarFollowers.length === 0) {
    return null;
  }

  return (
    <div className='account__header__familiar-followers'>
      <AvatarGroup compact>
        {familiarFollowers.slice(0, 3).map((account) => (
          <Avatar withLink key={account.id} account={account} size={28} />
        ))}
      </AvatarGroup>
      <FamiliarFollowersReadout familiarFollowers={familiarFollowers} />
    </div>
  );
};
