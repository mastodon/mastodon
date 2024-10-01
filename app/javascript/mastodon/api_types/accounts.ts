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

// See app/serializers/rest/account_serializer.rb
export interface ApiAccountJSON {
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
  roles?: ApiAccountJSON[];
  statuses_count: number;
  uri: string;
  url: string;
  username: string;
  moved?: ApiAccountJSON;
  suspended?: boolean;
  limited?: boolean;
  memorial?: boolean;
  hide_collections: boolean;
}
