import type { ApiCollectionJSON } from '@/mastodon/api_types/collections';
import type { ApiSearchResultsJSON } from '@/mastodon/api_types/search';
import type { ApiHashtagJSON } from '@/mastodon/api_types/tags';

export type RecentSearchType = 'account' | 'hashtag' | 'accounts' | 'statuses';

export interface RecentSearch {
  q: string;
  type?: RecentSearchType;
}

export interface SearchResults {
  accounts: string[];
  statuses: string[];
  hashtags: ApiHashtagJSON[];
  collections: ApiCollectionJSON[];
}

export const createSearchResults = (serverJSON: ApiSearchResultsJSON) => ({
  accounts: serverJSON.accounts.map((account) => account.id),
  statuses: serverJSON.statuses.map((status) => status.id),
  hashtags: serverJSON.hashtags,
  collections: serverJSON.collections,
});
