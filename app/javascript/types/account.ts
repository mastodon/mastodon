import type { Record } from 'immutable';

import type { components } from '../../../openapi/lib/mastodon';

type AccountApiRawValues = components['schemas']['account'];

type CustomEmoji = Record<components['schemas']['custom_emoji']>;
type AccountField = Record<components['schemas']['account_field']>;
type AccountRole = Record<components['schemas']['account_role']>;

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
