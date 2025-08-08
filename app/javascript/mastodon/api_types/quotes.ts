import type { ApiStatusJSON } from './statuses';

export type ApiQuoteState = 'accepted' | 'pending' | 'revoked' | 'unauthorized';
export type ApiQuotePolicy = 'public' | 'followers' | 'nobody';

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
