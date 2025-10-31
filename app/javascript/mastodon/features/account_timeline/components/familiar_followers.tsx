import { FormattedMessage } from 'react-intl';

import { Avatar } from '@/mastodon/components/avatar';
import { AvatarGroup } from '@/mastodon/components/avatar_group';
import { LinkedDisplayName } from '@/mastodon/components/display_name';
import type { Account } from '@/mastodon/models/account';

import { useFetchFamiliarFollowers } from '../hooks/familiar_followers';

const FamiliarFollowersReadout: React.FC<{ familiarFollowers: Account[] }> = ({
  familiarFollowers,
}) => {
  const messageData = {
    name1: (
      <LinkedDisplayName
        displayProps={{ account: familiarFollowers.at(0), variant: 'simple' }}
      />
    ),
    name2: (
      <LinkedDisplayName
        displayProps={{ account: familiarFollowers.at(1), variant: 'simple' }}
      />
    ),
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
  const { familiarFollowers, isLoading } = useFetchFamiliarFollowers({
    accountId,
  });

  if (isLoading || familiarFollowers.length === 0) {
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
