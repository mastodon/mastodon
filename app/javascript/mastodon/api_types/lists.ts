// See app/serializers/rest/list_serializer.rb

import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

export type RepliesPolicyType = 'list' | 'followed' | 'none';

export type ListType = 'private_list' | 'public_list';

export interface ApiListJSON {
  id: string;
  url?: string;
  title: string;
  slug?: string;
  type: ListType;
  description: string;
  created_at: string;
  updated_at: string;
  exclusive: boolean;
  replies_policy: RepliesPolicyType;
  account?: ApiAccountJSON;
}
