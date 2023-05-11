import type { Record } from 'immutable';

type CustomEmoji = Record<{
  shortcode: string;
  static_url: string;
  url: string;
}>;

type AccountField = Record<{
  name: string;
  value: string;
  verified_at: string | null;
}>;

interface AccountApiResponseValues {
  acct: string;
  avatar: string;
  avatar_static: string;
  bot: boolean;
  created_at: string;
  discoverable: boolean;
  display_name: string;
  emojis: CustomEmoji[];
  fields: AccountField[];
  followers_count: number;
  following_count: number;
  group: boolean;
  header: string;
  header_static: string;
  id: string;
  last_status_at: string;
  locked: boolean;
  note: string;
  statuses_count: number;
  url: string;
  username: string;
}

type NormalizedAccountField = Record<{
  name_emojified: string;
  value_emojified: string;
  value_plain: string;
}>;

interface NormalizedAccountValues {
  display_name_html: string;
  fields: NormalizedAccountField[];
  note_emojified: string;
  note_plain: string;
}

export type Account = Record<
  AccountApiResponseValues & NormalizedAccountValues
>;
