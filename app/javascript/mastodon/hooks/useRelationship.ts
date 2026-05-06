import { useEffect } from 'react';

import { fetchRelationships } from '../actions/accounts';
import { useAppDispatch, useAppSelector } from '../store';

export function useRelationship(accountId?: string | null) {
  const relationship = useAppSelector((state) =>
    accountId ? state.relationships.get(accountId) : null,
  );

  const dispatch = useAppDispatch();
  useEffect(() => {
    if (accountId && !relationship) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [accountId, dispatch, relationship]);

  return relationship;
}
