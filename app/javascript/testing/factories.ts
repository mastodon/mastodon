import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

interface FactoryOptions<T> {
  id?: string;
  data?: Partial<T>;
}

export function accountFactory({
  id,
  data,
}: FactoryOptions<ApiAccountJSON> = {}) {
  return {
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
  };
}
