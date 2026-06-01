import type { ApiAccountJSON } from './accounts';
import type { ApiCollectionJSON } from './collections';
import type { ApiStatusJSON } from './statuses';
import type { ApiHashtagJSON } from './tags';

export type ApiSearchType = 'accounts' | 'statuses' | 'hashtags';

export interface ApiSearchResultsJSON {
  accounts: ApiAccountJSON[];
  statuses: ApiStatusJSON[];
  hashtags: ApiHashtagJSON[];
  collections: ApiCollectionJSON[];
}
