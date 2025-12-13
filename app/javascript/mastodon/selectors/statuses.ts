import { createSelector } from '@reduxjs/toolkit';
import type { OrderedSet as ImmutableOrderedSet } from 'immutable';

import type { RootState } from 'mastodon/store';

export const getStatusList = createSelector(
  [
    (
      state: RootState,
      type: 'favourites' | 'bookmarks' | 'pins' | 'trending',
    ) =>
      state.status_lists.getIn([type, 'items']) as ImmutableOrderedSet<string>,
  ],
  (items) => items.toList(),
);
