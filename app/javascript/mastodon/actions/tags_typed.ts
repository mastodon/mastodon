import { createAction } from '@reduxjs/toolkit';

import {
  apiGetTag,
  apiFollowTag,
  apiUnfollowTag,
  apiFeatureTag,
  apiUnfeatureTag,
  apiGetFollowedTags,
} from 'mastodon/api/tags';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const fetchFollowedHashtags = createDataLoadingThunk(
  'tags/fetch-followed',
  async ({ next }: { next?: string } = {}) => {
    const response = await apiGetFollowedTags(next);
    return {
      ...response,
      replace: !next,
    };
  },
);

export const markFollowedHashtagsStale = createAction(
  'tags/mark-followed-stale',
);

export const fetchHashtag = createDataLoadingThunk(
  'tags/fetch',
  ({ tagId }: { tagId: string }) => apiGetTag(tagId),
);

export const followHashtag = createDataLoadingThunk(
  'tags/follow',
  ({ tagId }: { tagId: string }) => apiFollowTag(tagId),
  (_, { dispatch }) => {
    void dispatch(markFollowedHashtagsStale());
  },
);

export const unfollowHashtag = createDataLoadingThunk(
  'tags/unfollow',
  ({ tagId }: { tagId: string }) => apiUnfollowTag(tagId),
);

export const featureHashtag = createDataLoadingThunk(
  'tags/feature',
  ({ tagId }: { tagId: string }) => apiFeatureTag(tagId),
);

export const unfeatureHashtag = createDataLoadingThunk(
  'tags/unfeature',
  ({ tagId }: { tagId: string }) => apiUnfeatureTag(tagId),
);
