import { createSelector } from '@reduxjs/toolkit';
import { OrderedSet as ImmutableOrderedSet } from 'immutable';

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

// Per-folder bookmark list selector
export const getBookmarkFolderStatusList = createSelector(
  [
    (state: RootState, folderId: string) =>
      state.status_lists.getIn(
        ['bookmark_folders', folderId, 'items'],
        ImmutableOrderedSet<string>(),
      ) as ImmutableOrderedSet<string>,
  ],
  (items) => items.toList(),
);
