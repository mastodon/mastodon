import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

export type ApiSuggestionSourceJSON =
  | 'featured'
  | 'most_followed'
  | 'most_interactions'
  | 'similar_to_recently_followed'
  | 'friends_of_friends';

export interface ApiSuggestionJSON {
  sources: [ApiSuggestionSourceJSON, ...ApiSuggestionSourceJSON[]];
  account: ApiAccountJSON;
}
