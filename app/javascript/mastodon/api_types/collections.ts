// See app/serializers/rest/base_collection_serializer.rb

import type { ApiAccountJSON } from './accounts';
import type { ApiTagJSON } from './statuses';

interface CollectionAccountItem {
  account: ApiAccountJSON;
  state: 'pending' | 'accepted' | 'rejected' | 'revoked';
  position: number;
}

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

export interface ApiFullCollectionJSON extends ApiBaseCollectionJSON {
  account: ApiAccountJSON;
  items: CollectionAccountItem[];
}

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
