import type { ApiAccountFieldJSON } from './accounts';

export interface ApiProfileJSON {
  id: string;
  display_name: string;
  note: string;
  fields: ApiAccountFieldJSON[];
  avatar: string;
  avatar_static: string;
  avatar_description: string;
  header: string;
  header_static: string;
  header_description: string;
  locked: boolean;
  bot: boolean;
  hide_collections: boolean;
  discoverable: boolean;
  indexable: boolean;
  show_media: boolean;
  show_media_replies: boolean;
  show_featured: boolean;
  attribution_domains: string[];
}

export type ApiProfileUpdateParams = Partial<
  Pick<
    ApiProfileJSON,
    | 'display_name'
    | 'note'
    | 'locked'
    | 'bot'
    | 'hide_collections'
    | 'discoverable'
    | 'indexable'
    | 'show_media'
    | 'show_media_replies'
    | 'show_featured'
  >
> & {
  attribution_domains?: string[];
  fields_attributes?: Pick<ApiAccountFieldJSON, 'name' | 'value'>[];
};
