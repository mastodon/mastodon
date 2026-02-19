// See app/serializers/rest/base_collection_serializer.rb

import type { ApiAccountJSON } from './accounts';
import type { ApiTagJSON } from './statuses';

/**
 * Returned when fetching all collections for an account,
 * doesn't contain account and item data
 */
export interface ApiCollectionJSON {
  account_id: string;

  id: string;
  uri: string | null;
  local: boolean;
  item_count: number;

  name: string;
  description: string;
  tag: ApiTagJSON | null;
  language: string | null;
  sensitive: boolean;
  discoverable: boolean;

  created_at: string;
  updated_at: string;

  items: CollectionAccountItem[];
}

/**
 * Returned when fetching all collections for an account
 */
export interface ApiCollectionsJSON {
  collections: ApiCollectionJSON[];
}

/**
 * Returned when creating, updating, and adding to a collection
 */
export interface ApiWrappedCollectionJSON {
  collection: ApiCollectionJSON;
}

/**
 * Returned when fetching a single collection
 */
export interface ApiCollectionWithAccountsJSON extends ApiWrappedCollectionJSON {
  accounts: ApiAccountJSON[];
}

/**
 * Nested account item
 */
interface CollectionAccountItem {
  id: string;
  account_id?: string; // Only present when state is 'accepted' (or the collection is your own)
  state: 'pending' | 'accepted' | 'rejected' | 'revoked';
  position: number;
}

export interface WrappedCollectionAccountItem {
  collection_item: CollectionAccountItem;
}

/**
 * Payload types
 */

type CommonPayloadFields = Pick<
  ApiCollectionJSON,
  'name' | 'description' | 'sensitive' | 'discoverable'
> & {
  tag_name?: string | null;
  language?: ApiCollectionJSON['language'];
};

export interface ApiUpdateCollectionPayload extends Partial<CommonPayloadFields> {
  id: string;
}

export interface ApiCreateCollectionPayload extends CommonPayloadFields {
  account_ids?: string[];
}
