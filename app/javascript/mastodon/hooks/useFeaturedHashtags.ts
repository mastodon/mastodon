import { useEffect } from 'react';

import { fetchFeaturedTags } from '../actions/featured_tags';
import { selectAccountFeaturedTags } from '../selectors/accounts';
import { useAppDispatch, useAppSelector } from '../store';

import type { AccountId } from './useAccountId';

export function useFeaturedHashtags(accountId: AccountId) {
  const dispatch = useAppDispatch();

  useEffect(() => {
    if (accountId) {
      void dispatch(fetchFeaturedTags({ accountId }));
    }
  }, [accountId, dispatch]);
  const featuredTags = useAppSelector((state) =>
    accountId ? selectAccountFeaturedTags(state, accountId) : null,
  );

  return featuredTags;
}
