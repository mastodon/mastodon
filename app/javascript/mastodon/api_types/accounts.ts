import type { ApiCustomEmojiJSON } from './custom_emoji';

export interface ApiAccountFieldJSON {
  name: string;
  value: string;
  verified_at: string | null;
}

export interface ApiAccountRoleJSON {
  color: string;
  id: string;
  name: string;
}

// See app/serializers/rest/base_account_serializer.rb
export interface BaseApiAccountJSON {
  acct: string;
  avatar: string;
  avatar_static: string;
  bot: boolean;
  created_at: string;
  discoverable: boolean;
  indexable: boolean;
  display_name: string;
  emojis: ApiCustomEmojiJSON[];
  fields: ApiAccountFieldJSON[];
  followers_count: number;
  following_count: number;
  group: boolean;
  header: string;
  header_static: string;
  id: string;
  last_status_at: string;
  locked: boolean;
  noindex?: boolean;
  note: string;
  roles?: ApiAccountRoleJSON[];
  statuses_count: number;
  uri: string;
  url: string;
  username: string;
  suspended?: boolean;
  limited?: boolean;
  memorial?: boolean;
  hide_collections: boolean;
}

export interface ApiAccountJSON extends BaseApiAccountJSON {
  moved?: ApiAccountJSON;
}

export interface ShallowApiAccountJSON extends BaseApiAccountJSON {
  moved_to_account_id?: string;
}
