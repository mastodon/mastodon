import { useEffect } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { fetchAccountsFamiliarFollowers } from '@/mastodon/actions/accounts_familiar_followers';
import { getAccountFamiliarFollowers } from '@/mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const messages = defineMessages({
  familiar_followers: {
    id: 'account.familiar_followers',
    defaultMessage: 'Followed by:',
  },
});

export const FamiliarFollowers: React.FC<{ accountId: string }> = ({
  accountId,
}) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const familiarFollowers = useAppSelector((state) =>
    getAccountFamiliarFollowers(state, accountId),
  );

  useEffect(() => {
    void dispatch(fetchAccountsFamiliarFollowers({ id: accountId }));
  }, [dispatch, accountId]);

  if (familiarFollowers.length === 0) {
    return null;
  }

  return (
    <>
      {intl.formatMessage(messages.familiar_followers)}
      {familiarFollowers.map((fellow) => (
        <div key={fellow.id}>{fellow.display_name}</div>
      ))}
    </>
  );
};
