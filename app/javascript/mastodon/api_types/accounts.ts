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

type ApiFeaturePolicy =
  | 'public'
  | 'followers'
  | 'following'
  | 'disabled'
  | 'unsupported_policy';

type ApiUserFeaturePolicy =
  | 'automatic'
  | 'manual'
  | 'denied'
  | 'missing'
  | 'unknown';

interface ApiFeaturePolicyJSON {
  automatic: ApiFeaturePolicy[];
  manual: ApiFeaturePolicy[];
  current_user: ApiUserFeaturePolicy;
}

// See app/serializers/rest/account_serializer.rb
export interface BaseApiAccountJSON {
  acct: string;
  avatar: string;
  avatar_static: string;
  bot: boolean;
  created_at: string;
  discoverable?: boolean;
  indexable: boolean;
  display_name: string;
  emojis: ApiCustomEmojiJSON[];
  feature_approval: ApiFeaturePolicyJSON;
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
  url?: string;
  username: string;
  moved?: ApiAccountJSON;
  suspended?: boolean;
  limited?: boolean;
  memorial?: boolean;
  hide_collections: boolean;
}

// See app/serializers/rest/muted_account_serializer.rb
export interface ApiMutedAccountJSON extends BaseApiAccountJSON {
  mute_expires_at?: string | null;
}

// For now, we have the same type representing both `Account` and `MutedAccount`
// objects, but we should refactor this in the future.
export type ApiAccountJSON = ApiMutedAccountJSON;

// See app/serializers/rest/familiar_followers_serializer.rb
export type ApiFamiliarFollowersJSON = {
  id: string;
  accounts: ApiAccountJSON[];
}[];
