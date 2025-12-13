import type { ApiHashtagJSON } from 'mastodon/api_types/tags';

export type Hashtag = ApiHashtagJSON;

export const createHashtag = (serverJSON: ApiHashtagJSON): Hashtag => ({
  ...serverJSON,
});
