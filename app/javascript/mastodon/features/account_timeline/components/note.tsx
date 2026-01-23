import { useEffect } from 'react';
import type { FC } from 'react';

import { fetchRelationships } from '@/mastodon/actions/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

export const AccountNote: FC<{ accountId: string }> = ({ accountId }) => {
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!relationship) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [accountId, dispatch, relationship]);

  if (!relationship?.note) {
    return null;
  }

  return <div>{relationship.note}</div>;
};
