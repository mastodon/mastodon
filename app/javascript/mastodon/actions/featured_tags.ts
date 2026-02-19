import { apiGetFeaturedTags } from 'mastodon/api/accounts';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const fetchFeaturedTags = createDataLoadingThunk(
  'accounts/featured_tags',
  ({ accountId }: { accountId: string }) => apiGetFeaturedTags(accountId),
);
