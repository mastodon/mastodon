import { useEffect } from 'react';

import { fetchAccountsFamiliarFollowers } from '@/mastodon/actions/accounts_familiar_followers';
import { getAccountFamiliarFollowers } from '@/mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { me } from 'mastodon/initial_state';

export const useFetchFamiliarFollowers = ({
  accountId,
}: {
  accountId?: string;
}) => {
  const dispatch = useAppDispatch();
  const familiarFollowers = useAppSelector((state) =>
    accountId ? getAccountFamiliarFollowers(state, accountId) : null,
  );

  const hasNoData = familiarFollowers === null;

  useEffect(() => {
    if (hasNoData && accountId && accountId !== me) {
      void dispatch(fetchAccountsFamiliarFollowers({ id: accountId }));
    }
  }, [dispatch, accountId, hasNoData]);

  return {
    familiarFollowers: hasNoData ? [] : familiarFollowers,
    isLoading: hasNoData,
  };
};
