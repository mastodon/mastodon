import { useEffect } from 'react';

import { fetchAccount } from '../actions/accounts';
import { createAppSelector, useAppDispatch, useAppSelector } from '../store';

export const accountSelector = createAppSelector(
  [
    (state) => state.accounts,
    (_, accountId: string | null | undefined) => accountId,
  ],
  (accounts, accountId) => (accountId ? accounts.get(accountId) : undefined),
);

export function useAccount(accountId: string | null | undefined) {
  const account = useAppSelector((state) => accountSelector(state, accountId));

  const dispatch = useAppDispatch();
  const accountInStore = !!account;
  useEffect(() => {
    if (accountId && !accountInStore) {
      dispatch(fetchAccount(accountId));
    }
  }, [accountId, accountInStore, dispatch]);

  return account;
}
