import {
  apiGetTag,
  apiFollowTag,
  apiUnfollowTag,
  apiFeatureTag,
  apiUnfeatureTag,
} from 'mastodon/api/tags';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const fetchHashtag = createDataLoadingThunk(
  'tags/fetch',
  ({ tagId }: { tagId: string }) => apiGetTag(tagId),
);

export const followHashtag = createDataLoadingThunk(
  'tags/follow',
  ({ tagId }: { tagId: string }) => apiFollowTag(tagId),
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
