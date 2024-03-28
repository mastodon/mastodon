// See app/serializers/rest/status_serializer.rb

import type { ApiAccountJSON } from './accounts';
import type { ApiCustomEmojiJSON } from './custom_emoji';
import type { ApiMediaAttachmentJSON } from './media_attachments';
import type { ApiPollJSON } from './polls';

// See app/modals/status.rb
export type StatusVisibility =
  | 'public'
  | 'unlisted'
  | 'private'
  // | 'limited' // This is never exposed to the API (they become `private`)
  | 'direct';

export interface ApiStatusApplicationJSON {
  name: string;
  website: string;
}

export interface ApiTagJSON {
  name: string;
  url: string;
}

export interface ApiMentionJSON {
  id: string;
  username: string;
  url: string;
  acct: string;
}

export interface ApiPreviewCardJSON {
  url: string;
  title: string;
  description: string;
  language: string;
  type: string;
  author_name: string;
  author_url: string;
  provider_name: string;
  provider_url: string;
  html: string;
  width: number;
  height: number;
  image: string;
  image_description: string;
  embed_url: string;
  blurhash: string;
  published_at: string;
}

export interface ApiStatusJSON {
  id: string;
  created_at: string;
  in_reply_to_id?: string;
  in_reply_to_account_id?: string;
  sensitive: boolean;
  spoiler_text?: string;
  visibility: StatusVisibility;
  language: string;
  uri: string;
  url: string;
  replies_count: number;
  reblogs_count: number;
  favorites_count: number;
  edited_at?: string;

  favorited?: boolean;
  reblogged?: boolean;
  muted?: boolean;
  bookmarked?: boolean;
  pinned?: boolean;

  // filtered: FilterResult[]
  filtered: unknown; // TODO
  content?: string;
  text?: string;

  reblog?: ApiStatusJSON;
  application?: ApiStatusApplicationJSON;
  account: ApiAccountJSON;
  media_attachments: ApiMediaAttachmentJSON[];
  mentions: ApiMentionJSON[];

  tags: ApiTagJSON[];
  emojis: ApiCustomEmojiJSON[];

  card?: ApiPreviewCardJSON;
  poll?: ApiPollJSON;
}
