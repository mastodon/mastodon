import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { createAppSelector } from '../store';

export const selectUserListWithoutMe = createAppSelector(
  [
    (state) => state.user_lists,
    (state) => (state.meta.get('me') as string | null) ?? null,
    (_state, listName: string) => listName,
    (_state, _listName, accountId?: string | null) => accountId ?? null,
  ],
  (lists, currentAccountId, listName, accountId) => {
    if (!accountId || !listName) {
      return null;
    }
    const list = lists.getIn([listName, accountId]) as
      | ImmutableMap<string, unknown>
      | undefined;
    if (!list) {
      return null;
    }

    // Returns the list except the current account.
    return {
      items: (
        list.get('items', ImmutableList<string>()) as ImmutableList<string>
      )
        .filter((id) => id !== currentAccountId)
        .toArray(),
      isLoading: !!list.get('isLoading', true),
      hasMore: !!list.get('hasMore', false),
    };
  },
);
