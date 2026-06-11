import type { RecordOf } from 'immutable';

import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import type {
  ApiFilterResultJSON,
  ApiMentionJSON,
  ApiPreviewCardAuthorJSON,
  ApiPreviewCardJSON,
  StatusVisibility,
} from 'mastodon/api_types/statuses';

import type { ApiCustomEmojiJSON } from '../api_types/custom_emoji';
import type { ApiMediaAttachmentJSON } from '../api_types/media_attachments';
import type { ApiQuoteJSON, ApiQuotePolicyJSON } from '../api_types/quotes';

export type { StatusVisibility } from 'mastodon/api_types/statuses';

// Temporary until we type it correctly
export type Status = Immutable.Map<string, unknown>;

export interface StatusShape {
  id: string;
  account: string;
  created_at: string;
  edited_at: string | null;
  application: {
    name: string;
    website: string | null;
  };
  hidden: boolean;
  language: string;
  muted: boolean;
  pinned: boolean;
  filtered: FilterResult[];
  sensitive: boolean;
  collapsed: boolean;
  uri: string;
  url: string;

  // Content
  content: string;
  contentHtml: string;
  in_reply_to_account_id: string | null;
  in_reply_to_id: string | null;
  search_index: string;
  spoilerHtml: string;
  spoiler_text: string;

  // Embeds
  card: CardShape | null;
  emojis: Pick<ApiCustomEmojiJSON, 'shortcode' | 'static_url' | 'url'>[];
  media_attachments: MediaAttachmentShape[];
  mentions: ApiMentionJSON[];
  poll: string | null;
  quote:
    | (Omit<ApiQuoteJSON, 'quoted_status'> & { quoted_status: string | null })
    | null;
  reblog: null;
  tagged_collections: [];
  tags: [];

  // Interactions
  bookmarked: boolean;
  favourited: boolean;
  favourites_count: number;
  quote_approval: ApiQuotePolicyJSON;
  quotes_count: number;
  reblogged: boolean;
  reblogs_count: number;
  replies_count: number;
  visibility: StatusVisibility;
}

export type CardShape = Omit<ApiPreviewCardJSON, 'authors'> & {
  authors: (Omit<ApiPreviewCardAuthorJSON, 'author'> & {
    accountId?: string;
  })[];
};

export type Card = RecordOf<CardShape>;

export type MediaAttachment = Immutable.Map<string, unknown>;

export type MediaAttachmentShape = Omit<
  ApiMediaAttachmentJSON,
  'remote_url'
> & {
  remote_url: string | null;
  translation?: string;
};

export type CollectionAttachment = RecordOf<ApiCollectionJSON>;

export type FilterResult = Omit<ApiFilterResultJSON, 'filter'> & {
  filter: string;
};
