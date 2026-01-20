// See app/serializers/rest/base_collection_serializer.rb

import type { ApiAccountJSON } from './accounts';
import type { ApiTagJSON } from './statuses';

/**
 * Returned when fetching all collections for an account,
 * doesn't contain account and item data
 */
export interface ApiBaseCollectionJSON {
  id: string;
  uri: string;
  local: boolean;
  item_count: number;

  name: string;
  tag?: ApiTagJSON;
  description: string;
  sensitive: boolean;
  discoverable: boolean;

  created_at: string;
  updated_at: string;
}

/**
 * Returned when fetching a single collection
 */
export interface ApiFullCollectionJSON extends ApiBaseCollectionJSON {
  account: ApiAccountJSON;
  items: CollectionAccountItem[];
}

/**
 * Nested account item
 */
interface CollectionAccountItem {
  account: ApiAccountJSON;
  state: 'pending' | 'accepted' | 'rejected' | 'revoked';
  position: number;
}

/**
 * Payload types
 */

type CommonPayloadFields = Pick<
  ApiBaseCollectionJSON,
  'name' | 'description' | 'sensitive' | 'discoverable'
> & {
  tag?: string;
};

export interface ApiPatchCollectionPayload extends Partial<CommonPayloadFields> {
  id: string;
}

export interface ApiCreateCollectionPayload extends CommonPayloadFields {
  account_ids?: string[];
}
