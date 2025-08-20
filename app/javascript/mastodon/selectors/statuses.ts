import type { OrderedSet as ImmutableOrderedSet } from 'immutable';

import { createAppSelector } from 'mastodon/store';

import type { Status, StatusVisibility } from '../models/status';

export const getStatusList = createAppSelector(
  [
    (state, type: 'favourites' | 'bookmarks' | 'pins' | 'trending') =>
      state.status_lists.getIn([type, 'items']) as ImmutableOrderedSet<string>,
  ],
  (items) => items.toList(),
);

export const canQuoteStatus = createAppSelector(
  [
    (state) => state.meta.get('me') as string | undefined,
    (_, status: Status) => status,
  ],
  (userId, status) => {
    const visibility = status.get('visibility') as StatusVisibility;
    return (
      status.getIn(['quote_approval', 'current_user']) === 'automatic' &&
      (['public', 'unlisted'].includes(visibility) ||
        (visibility === 'private' &&
          status.getIn(['account', 'id']) === userId))
    );
  },
);
