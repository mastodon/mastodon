import { Map as ImmutableMap } from 'immutable';

import type { ApiRelationshipJSON } from '@/mastodon/api_types/relationships';
import type { ApiStatusJSON } from '@/mastodon/api_types/statuses';
import type {
  CustomEmojiData,
  UnicodeEmojiData,
} from '@/mastodon/features/emoji/types';
import { createAccountFromServerJSON } from '@/mastodon/models/account';
import type { Status } from '@/mastodon/models/status';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

type FactoryOptions<T> = {
  id?: string;
} & Partial<T>;

type FactoryFunction<T> = (options?: FactoryOptions<T>) => T;

export const accountFactory: FactoryFunction<ApiAccountJSON> = ({
  id,
  ...data
} = {}) => ({
  id: id ?? '1',
  acct: 'testuser',
  avatar: '/avatars/original/missing.png',
  avatar_static: '/avatars/original/missing.png',
  username: 'testuser',
  display_name: 'Test User',
  bot: false,
  created_at: '2023-01-01T00:00:00.000Z',
  discoverable: true,
  emojis: [],
  fields: [],
  followers_count: 0,
  following_count: 0,
  group: false,
  header: '/header.png',
  header_static: '/header_static.png',
  indexable: true,
  last_status_at: '2023-01-01',
  locked: false,
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

export const accountFactoryState = (
  options: FactoryOptions<ApiAccountJSON> = {},
) => createAccountFromServerJSON(accountFactory(options));

export const statusFactory: FactoryFunction<ApiStatusJSON> = ({
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
  favorites_count: 0,
  account: accountFactory(),
  media_attachments: [],
  mentions: [],
  tags: [],
  emojis: [],
  content: '<p>This is a test status.</p>',
  ...data,
});

export const statusFactoryState = (
  options: FactoryOptions<ApiStatusJSON> = {},
) =>
  ImmutableMap<string, unknown>(
    statusFactory(options) as unknown as Record<string, unknown>,
  ) as unknown as Status;

export const relationshipsFactory: FactoryFunction<ApiRelationshipJSON> = ({
  id,
  ...data
} = {}) => ({
  id: id ?? '1',
  following: false,
  followed_by: false,
  blocking: false,
  blocked_by: false,
  languages: null,
  muting_notifications: false,
  note: '',
  requested_by: false,
  muting: false,
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
    ...data,
  };
}

export function customEmojiFactory(
  data: Partial<CustomEmojiData> = {},
): CustomEmojiData {
  return {
    shortcode: 'custom',
    static_url: 'emoji/custom/static',
    url: 'emoji/custom',
    visible_in_picker: true,
    ...data,
  };
}
