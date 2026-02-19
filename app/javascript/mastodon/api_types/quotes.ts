import type { ApiStatusJSON } from './statuses';

export type ApiQuoteState = 'accepted' | 'pending' | 'revoked' | 'unauthorized';
export type ApiQuotePolicy =
  | 'public'
  | 'followers'
  | 'following'
  | 'nobody'
  | 'unsupported_policy';
export type ApiUserQuotePolicy = 'automatic' | 'manual' | 'denied' | 'unknown';

interface ApiQuoteEmptyJSON {
  state: Exclude<ApiQuoteState, 'accepted'>;
  quoted_status: null;
}

interface ApiNestedQuoteJSON {
  state: 'accepted';
  quoted_status_id: string;
}

interface ApiQuoteAcceptedJSON {
  state: 'accepted';
  quoted_status: Omit<ApiStatusJSON, 'quote'> & {
    quote: ApiNestedQuoteJSON | ApiQuoteEmptyJSON;
  };
}

export type ApiQuoteJSON = ApiQuoteAcceptedJSON | ApiQuoteEmptyJSON;

export interface ApiQuotePolicyJSON {
  automatic: ApiQuotePolicy[];
  manual: ApiQuotePolicy[];
  current_user: ApiUserQuotePolicy;
}

export function isQuotePolicy(policy: string): policy is ApiQuotePolicy {
  return ['public', 'followers', 'nobody'].includes(policy);
}
