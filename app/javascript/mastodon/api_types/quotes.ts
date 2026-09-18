import type { ApiStatusJSON } from './statuses';

export type ApiQuoteState =
  | 'accepted'
  | 'pending'
  | 'revoked'
  | 'unauthorized'
  | 'deleted'
  | 'rejected'
  | 'blocked_account'
  | 'blocked_domain'
  | 'muted_account';
export type ApiQuoteStateValid =
  | 'accepted'
  | 'blocked_account'
  | 'blocked_domain'
  | 'muted_account';
export type ApiQuotePolicy =
  | 'public'
  | 'followers'
  | 'following'
  | 'nobody'
  | 'unsupported_policy';
export type ApiUserQuotePolicy = 'automatic' | 'manual' | 'denied' | 'unknown';

interface ApiQuoteEmptyJSON {
  state: Exclude<ApiQuoteState, ApiQuoteStateValid>;
  quoted_status: null;
}

interface ApiNestedQuoteJSON {
  state: ApiQuoteStateValid;
  quoted_status_id: string;
}

export type ApiQuotedStatusJSON = Omit<ApiStatusJSON, 'quote'> & {
  quote?: ApiNestedQuoteJSON | ApiQuoteEmptyJSON;
};

interface ApiQuoteAcceptedJSON {
  state: ApiQuoteStateValid;
  quoted_status: ApiQuotedStatusJSON;
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
