import type { Record } from 'immutable';

import type { CustomEmoji, CustomEmojiRawValues } from './custom_emoji';

interface AccountFieldRawValues {
  name: string;
  value: string;
  verified_at: string | null;
}
type AccountField = Record<AccountFieldRawValues>;

interface AccountRoleRawValues {
  color: string;
  id: string;
  name: string;
}
type AccountRole = Record<AccountRoleRawValues>;

interface AccountApiRawValues {
  acct: string;
  avatar: string;
  avatar_static: string;
  bot: boolean;
  created_at: string;
  discoverable: boolean;
  display_name: string;
  emojis: CustomEmojiRawValues[];
  fields: AccountFieldRawValues[];
  followers_count: number;
  following_count: number;
  group: boolean;
  header: string;
  header_static: string;
  id: string;
  last_status_at: string;
  locked: boolean;
  noindex: boolean;
  note: string;
  roles: AccountRoleRawValues[];
  statuses_count: number;
  url: string;
  username: string;
}

interface NormalizedAccountValues {
  display_name_html: string;
  emojis: CustomEmoji[];
  fields: AccountField[];
  note_emojified: string;
  note_plain: string;
  roles: AccountRole[];
}

export type Account = Record<
  Exclude<AccountApiRawValues, 'emojis' | 'fields' | 'roles'> &
    NormalizedAccountValues
>;
