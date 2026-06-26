import { fromJS } from 'immutable';

import type { PartialDeep } from 'type-fest';

import { normalizeStatus } from '@/mastodon/actions/importer/statuses';
import type {
  ApiAudioAttachmentJSON,
  ApiGifvAttachmentJSON,
  ApiImageAttachmentJSON,
  ApiMediaAttachmentJSON,
  ApiVideoAttachmentJSON,
  BaseApiMediaAttachmentJSON,
} from '@/mastodon/api_types/media_attachments';
import type { ApiPollJSON } from '@/mastodon/api_types/polls';
import type { ApiQuotedStatusJSON } from '@/mastodon/api_types/quotes';
import type { ApiRelationshipJSON } from '@/mastodon/api_types/relationships';
import type { ApiStatusJSON } from '@/mastodon/api_types/statuses';
import type {
  CustomEmojiData,
  UnicodeEmojiData,
} from '@/mastodon/features/emoji/types';
import type { AccountShapeFull } from '@/mastodon/models/account';
import {
  accountDefaultValues,
  createAccountFromServerJSON,
} from '@/mastodon/models/account';
import type { AnnualReport } from '@/mastodon/models/annual_report';
import { CustomEmojiFactory } from '@/mastodon/models/custom_emoji';
import type { Poll } from '@/mastodon/models/poll';
import type { Status } from '@/mastodon/models/status';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

type FactoryOptions<T> = {
  id?: string;
} & Partial<T>;

type FactoryFunction<T> = (options?: FactoryOptions<T>) => T;

export const accountFactoryAPI: FactoryFunction<ApiAccountJSON> = ({
  id,
  ...data
} = {}) => ({
  id: id ?? '1',
  acct: 'testuser',
  avatar: '/avatars/original/missing.png',
  avatar_static: '/avatars/original/missing.png',
  avatar_description: '',
  username: 'testuser',
  display_name: 'Test User',
  bot: false,
  created_at: '2023-01-01T00:00:00.000Z',
  discoverable: true,
  emojis: [],
  feature_approval: {
    automatic: [],
    manual: [],
    current_user: 'missing',
  },
  fields: [],
  followers_count: 0,
  following_count: 0,
  group: false,
  header: '/header.png',
  header_static: '/header_static.png',
  header_description: '',
  indexable: true,
  last_status_at: '2023-01-01',
  locked: false,
  show_featured: true,
  show_media: true,
  show_media_replies: true,
  mute_expires_at: null,
  note: 'This is a test user account.',
  statuses_count: 0,
  suspended: false,
  url: '/@testuser',
  uri: '/users/testuser',
  noindex: false,
  roles: [],
  hide_collections: false,
  ...data,
});

export const accountFactory = (
  options: FactoryOptions<ApiAccountJSON> = {},
): AccountShapeFull => {
  const accountJSON = accountFactoryAPI(options);
  return {
    ...accountJSON,
    ...accountDefaultValues,
    moved: accountJSON.moved?.id ?? null,
    display_name_html: accountJSON.display_name,
    note_emojified: accountJSON.note,
    note_plain: accountJSON.note,
    emojis: accountJSON.emojis.map((emoji) => ({
      category: '',
      featured: false,
      ...emoji,
    })),
    fields: accountJSON.fields.map((field) => ({
      name_emojified: field.name,
      value_emojified: field.value,
      value_plain: field.value,
      ...field,
    })),
    roles: accountJSON.roles ?? [],
  };
};

export const accountFactoryState = (
  options: FactoryOptions<ApiAccountJSON> = {},
) => createAccountFromServerJSON(accountFactoryAPI(options));

export const statusFactoryAPI: FactoryFunction<ApiStatusJSON> = ({
  id,
  ...data
} = {}) => ({
  id: id ?? '1',
  created_at: '2023-01-01T00:00:00.000Z',
  sensitive: false,
  visibility: 'public',
  language: 'en',
  uri: 'https://example.com/status/1',
  url: 'https://example.com/status/1',
  replies_count: 0,
  reblogs_count: 0,
  quotes_count: 0,
  favourites_count: 0,
  account: accountFactoryAPI(),
  media_attachments: [],
  mentions: [],
  tags: [],
  emojis: [],
  tagged_collections: [],
  content:
    data.text
      ?.split('\n')
      .map((line) => `<p>${line}</p>`)
      .join('\n') ?? '<p>This is a test status.</p>',
  ...data,
});

export const statusFactory = (options: FactoryOptions<ApiStatusJSON> = {}) =>
  normalizeStatus(statusFactoryAPI(options));

export const statusFactoryState = (
  options: FactoryOptions<ApiStatusJSON> = {},
) => fromJS(statusFactory(options)) as unknown as Status; // Convert to unknown to avoid excessive type recursion

export const statusQuotedFactoryAPI: FactoryFunction<ApiQuotedStatusJSON> = (
  options = {},
) => {
  const { quote, ...status } = options;
  return {
    ...statusFactoryAPI(status),
    quote: quote
      ? {
          ...quote,
        }
      : undefined,
  };
};

const baseAttachment = {
  id: '1',
  url: 'https://example.com/image/1',
  preview_url: 'https://example.com/image/1/preview',
  blurhash: '',
} as const;
const imageMeta = {
  width: 100,
  height: 100,
  aspect: 1,
  size: '100x100',
} as const;
const videoMeta = {
  width: 100,
  height: 100,
  frame_rate: '24',
  duration: 120,
  bitrate: 100,
} as const;
const colorsMeta = {
  background: '#ffffff',
  foreground: '#000000',
  accent: '#ff0000',
} as const;

type MediaFactoryArg<T extends BaseApiMediaAttachmentJSON> = Omit<
  PartialDeep<T>,
  'type'
>;

export const imageAttachmentFactoryAPI = (
  data: MediaFactoryArg<ApiImageAttachmentJSON> = {},
): ApiImageAttachmentJSON => ({
  ...baseAttachment,
  ...data,
  type: 'image',
  meta: {
    original: { ...imageMeta, ...data.meta?.original },
    small: { ...imageMeta, ...data.meta?.small },
  },
});

export const videoAttachmentFactoryAPI = (
  data: MediaFactoryArg<ApiVideoAttachmentJSON> = {},
): ApiVideoAttachmentJSON => ({
  ...baseAttachment,
  ...data,
  type: 'video',
  meta: {
    colors: { ...colorsMeta, ...data.meta?.colors },
    original: { ...videoMeta, ...data.meta?.original },
    small: { ...imageMeta, ...data.meta?.small },
    focus: {
      x: 0,
      y: 0,
      ...data.meta?.focus,
    },
  },
});

export const audioAttachmentFactoryAPI = (
  data: MediaFactoryArg<ApiAudioAttachmentJSON> = {},
): ApiAudioAttachmentJSON => ({
  ...baseAttachment,
  ...data,
  type: 'audio',
  meta: {
    colors: { ...colorsMeta, ...data.meta?.colors },
    original: { ...videoMeta, ...data.meta?.original },
    small: { ...imageMeta, ...data.meta?.small },
  },
});

export const gifvAttachmentFactoryAPI = (
  data: MediaFactoryArg<ApiGifvAttachmentJSON> = {},
): ApiGifvAttachmentJSON => ({
  ...baseAttachment,
  ...data,
  type: 'gifv',
  meta: {
    original: { ...videoMeta, ...data.meta?.original },
    small: { ...imageMeta, ...data.meta?.small },
  },
});

export function mediaAttachmentFactoryAPI(
  data: PartialDeep<ApiMediaAttachmentJSON> = {},
): ApiMediaAttachmentJSON {
  switch (data.type ?? 'image') {
    case 'image':
      return imageAttachmentFactoryAPI(
        data as PartialDeep<ApiImageAttachmentJSON>,
      );
    case 'video':
      return videoAttachmentFactoryAPI(
        data as PartialDeep<ApiVideoAttachmentJSON>,
      );
    case 'audio':
      return audioAttachmentFactoryAPI(
        data as PartialDeep<ApiAudioAttachmentJSON>,
      );
    case 'gifv':
      return gifvAttachmentFactoryAPI(
        data as PartialDeep<ApiGifvAttachmentJSON>,
      );
    default: {
      return {
        ...baseAttachment,
        meta: {},
        ...data,
        type: 'unknown',
      };
    }
  }
}

export const pollFactoryAPI: FactoryFunction<ApiPollJSON> = (data = {}) => ({
  id: '1',
  expires_at: '',
  expired: false,
  multiple: false,
  voters_count: 0,
  votes_count: 0,
  voted: false,
  options: [
    {
      title: 'Option 1',
      votes_count: 0,
    },
    {
      title: 'Option 2',
      votes_count: 0,
    },
  ],
  emojis: [],
  ...data,
});

export const pollFactoryState = (
  data: FactoryOptions<ApiPollJSON> = {},
): Poll => ({
  ...pollFactoryAPI(data),
  emojis: data.emojis?.map(CustomEmojiFactory) ?? [],
  options:
    data.options?.map((option) => ({
      voted: false,
      titleHtml: option.title,
      translation: null,
      ...option,
    })) ?? [],
});

export const relationshipsFactoryAPI: FactoryFunction<ApiRelationshipJSON> = ({
  id,
  ...data
} = {}) => ({
  id: id ?? '1',
  following: false,
  followed_by: false,
  blocking: false,
  blocked_by: false,
  languages: null,
  muting: false,
  muting_notifications: false,
  muting_expires_at: null,
  note: '',
  requested_by: false,
  requested: false,
  domain_blocking: false,
  endorsed: false,
  notifying: false,
  showing_reblogs: true,
  ...data,
});

export function unicodeEmojiFactory(
  data: Partial<UnicodeEmojiData> = {},
): UnicodeEmojiData {
  return {
    hexcode: 'test',
    label: 'Test',
    unicode: '🧪',
    shortcodes: ['test_emoji'],
    tokens: ['emoji', 'test'],
    group: 1,
    order: 1,
    ...data,
  };
}

export function customEmojiFactory(
  data: Partial<CustomEmojiData> = {},
): CustomEmojiData {
  return {
    shortcode: 'custom',
    static_url: '/custom-emoji/logo.svg',
    url: '/custom-emoji/logo.svg',
    visible_in_picker: true,
    tokens: ['custom'],
    ...data,
  };
}

interface AnnualReportState {
  state: 'available';
  report: AnnualReport;
}

interface AnnualReportFactoryOptions {
  account_id?: string;
  status_id?: string;
  archetype?: AnnualReport['data']['archetype'];
  year?: number;
  top_hashtag?: AnnualReport['data']['top_hashtags'][0];
  without_posts?: boolean;
}

export function annualReportFactory({
  account_id = '1',
  status_id = '1',
  archetype = 'lurker',
  year,
  top_hashtag,
  without_posts = false,
}: AnnualReportFactoryOptions = {}): AnnualReportState {
  return {
    state: 'available',
    report: {
      schema_version: 2,
      share_url: '#',
      account_id,
      year: year ?? 2025,
      data: {
        archetype,
        time_series: [
          {
            month: 1,
            statuses: 0,
            followers: 0,
            following: 0,
          },
          {
            month: 2,
            statuses: 0,
            followers: 0,
            following: 0,
          },
          {
            month: 3,
            statuses: 0,
            followers: 0,
            following: 0,
          },
          {
            month: 4,
            statuses: 0,
            followers: 0,
            following: 0,
          },
          {
            month: 5,
            statuses: without_posts ? 0 : 1,
            followers: 1,
            following: 3,
          },
          {
            month: 6,
            statuses: without_posts ? 0 : 7,
            followers: 1,
            following: 0,
          },
          {
            month: 7,
            statuses: without_posts ? 0 : 2,
            followers: 0,
            following: 0,
          },
          {
            month: 8,
            statuses: without_posts ? 0 : 2,
            followers: 0,
            following: 0,
          },
          {
            month: 9,
            statuses: without_posts ? 0 : 11,
            followers: 0,
            following: 1,
          },
          {
            month: 10,
            statuses: without_posts ? 0 : 12,
            followers: 0,
            following: 1,
          },
          {
            month: 11,
            statuses: without_posts ? 0 : 6,
            followers: 0,
            following: 1,
          },
          {
            month: 12,
            statuses: without_posts ? 0 : 4,
            followers: 0,
            following: 0,
          },
        ],
        top_hashtags: top_hashtag ? [top_hashtag] : [],
        top_statuses: {
          by_reblogs: status_id,
          by_replies: status_id,
          by_favourites: status_id,
        },
      },
    },
  };
}
