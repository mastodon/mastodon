import type { RecordOf } from 'immutable';

import type { ApiCollectionJSON } from '@/mastodon/api_types/collections';
import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import type {
  ApiAudioAttachmentJSON,
  ApiGifvAttachmentJSON,
  ApiImageAttachmentJSON,
  ApiMediaAttachmentJSON,
  ApiUnknownAttachmentJSON,
  ApiVideoAttachmentJSON,
  MediaAttachmentType,
} from '@/mastodon/api_types/media_attachments';
import type {
  ApiQuoteJSON,
  ApiQuotePolicyJSON,
} from '@/mastodon/api_types/quotes';
import type {
  ApiFilterResultJSON,
  ApiMentionJSON,
  ApiPreviewCardAuthorJSON,
  ApiPreviewCardJSON,
  ApiStatusTranslationJSON,
  ApiTagJSON,
  StatusVisibility,
} from '@/mastodon/api_types/statuses';

import type { AccountShapeFull } from './account';

export type { StatusVisibility } from '@/mastodon/api_types/statuses';

// Temporary until we type it correctly
export type Status = Immutable.Map<string, unknown>;

export interface StatusShape {
  id: string;
  account: string;
  created_at: string;
  edited_at?: string;
  application: {
    name: string;
    website?: string;
  };
  hidden: boolean;
  language: string;
  muted: boolean;
  pinned: boolean;
  filtered: FilterResult[];
  sensitive: boolean;
  collapsed: boolean | null;
  uri: string;
  url: string | null;

  // Content
  content: string;
  contentHtml: string;
  in_reply_to_account_id?: string;
  in_reply_to_id?: string;
  search_index?: string;
  spoilerHtml?: string;
  spoiler_text?: string;

  // Embeds
  card?: CardShape;
  emojis: Pick<ApiCustomEmojiJSON, 'shortcode' | 'static_url' | 'url'>[];
  media_attachments: MediaAttachmentShape[];
  mentions: ApiMentionJSON[];
  poll?: string;
  quote?: Omit<ApiQuoteJSON, 'quoted_status'> & {
    quoted_status?: string;
  };
  reblog?: string;
  tagged_collections: ApiCollectionJSON[];
  tags: ApiTagJSON[];
  translation?: StatusTranslation;

  // Interactions
  bookmarked: boolean;
  favourited: boolean;
  favourites_count: number;
  quote_approval: ApiQuotePolicyJSON | null;
  quotes_count: number;
  reblogged: boolean;
  reblogs_count: number;
  replies_count: number;
  visibility: StatusVisibility;
}
export type ExpandedStatusShape = Omit<StatusShape, 'account' | 'reblog'> & {
  account: AccountShapeFull;
  reblog?: Omit<ExpandedStatusShape, 'reblog'>;
};

export type CardShape = Omit<ApiPreviewCardJSON, 'authors'> & {
  authors: (Omit<ApiPreviewCardAuthorJSON, 'author'> & {
    accountId?: string;
  })[];
};

export type Card = RecordOf<CardShape>;

export type MediaAttachment = Immutable.Map<string, unknown>;

export type MediaAttachmentShape<
  TAttachmentJSON extends ApiMediaAttachmentJSON = ApiMediaAttachmentJSON,
> = Omit<TAttachmentJSON, 'remote_url'> & {
  remote_url: string | null;
  translation?: {
    description: string;
  };
};

export function isMediaAttachmentOfType(
  attachment: MediaAttachmentShape,
  type: 'image',
): attachment is MediaAttachmentShape<ApiImageAttachmentJSON>;
export function isMediaAttachmentOfType(
  attachment: MediaAttachmentShape,
  type: 'video',
): attachment is MediaAttachmentShape<ApiVideoAttachmentJSON>;
export function isMediaAttachmentOfType(
  attachment: MediaAttachmentShape,
  type: 'gifv',
): attachment is MediaAttachmentShape<ApiGifvAttachmentJSON>;
export function isMediaAttachmentOfType(
  attachment: MediaAttachmentShape,
  type: 'audio',
): attachment is MediaAttachmentShape<ApiAudioAttachmentJSON>;
export function isMediaAttachmentOfType(
  attachment: MediaAttachmentShape,
  type: 'unknown',
): attachment is MediaAttachmentShape<ApiUnknownAttachmentJSON>;
export function isMediaAttachmentOfType(
  attachment: MediaAttachmentShape,
  type: MediaAttachmentType,
) {
  return attachment.type === type;
}

export type CollectionAttachment = RecordOf<ApiCollectionJSON>;

export type FilterResult = Omit<ApiFilterResultJSON, 'filter'> & {
  filter: string;
};

export type StatusTranslation = Omit<ApiStatusTranslationJSON, 'poll'>;
