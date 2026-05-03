import { OrderedSet as ImmutableOrderedSet } from 'immutable';

import { createAppSelector } from 'mastodon/store';

import type { StatusShape } from '../models/status';

export const getStatusList = createAppSelector(
  [
    (state, type: 'favourites' | 'bookmarks' | 'pins' | 'trending') =>
      state.status_lists.getIn([type, 'items']) as ImmutableOrderedSet<string>,
  ],
  (items) => items.toList(),
);

export const selectPlainStatus = createAppSelector(
  [(state, statusId: string) => state.statuses.get(statusId)],
  (status) => {
    if (!status) {
      return null;
    }
    return status.toJS() as unknown as StatusShape;
  },
);

// Per-folder bookmark list selector
export const getBookmarkFolderStatusList = createAppSelector(
  [
    (state, folderId: string) =>
      state.status_lists.getIn(
        ['bookmark_folders', folderId, 'items'],
        ImmutableOrderedSet<string>(),
      ) as ImmutableOrderedSet<string>,
  ],
  (items) => items.toList(),
);
