import type { ApiSearchResultsJSON } from 'mastodon/api_types/search';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';

export type SearchType = 'account' | 'hashtag' | 'accounts' | 'statuses';

export interface RecentSearch {
  q: string;
  type?: SearchType;
}

export interface SearchResults {
  accounts: string[];
  statuses: string[];
  hashtags: ApiHashtagJSON[];
}

export const createSearchResults = (serverJSON: ApiSearchResultsJSON) => ({
  accounts: serverJSON.accounts.map((account) => account.id),
  statuses: serverJSON.statuses.map((status) => status.id),
  hashtags: serverJSON.hashtags,
});
