import type { RecordOf } from 'immutable';
import { List as ImmutableList, Record as ImmutableRecord } from 'immutable';

import escapeTextContentForBrowser from 'escape-html';

import type {
  ApiAccountFieldJSON,
  ApiAccountRoleJSON,
  ApiAccountJSON,
} from 'mastodon/api_types/accounts';
import type { AccountCategory } from 'mastodon/models/account_categories';
import { mapCategoriesFromJSON } from 'mastodon/models/account_categories';
import { unescapeHTML } from 'mastodon/utils/html';

import { CustomEmojiFactory } from './custom_emoji';
import type { CustomEmoji } from './custom_emoji';

// AccountField
export interface AccountFieldShape extends Required<ApiAccountFieldJSON> {
  name_emojified: string;
  value_emojified: string;
  value_plain: string | null;
}

type AccountField = RecordOf<AccountFieldShape>;

const AccountFieldFactory = ImmutableRecord<AccountFieldShape>({
  name: '',
  value: '',
  verified_at: null,
  name_emojified: '',
  value_emojified: '',
  value_plain: null,
});

// AccountRole
export type AccountRoleShape = ApiAccountRoleJSON;
export type AccountRole = RecordOf<AccountRoleShape>;

const AccountRoleFactory = ImmutableRecord<AccountRoleShape>({
  color: '',
  id: '',
  name: '',
});

// Account
export interface AccountShape
  extends Required<
    Omit<
      ApiAccountJSON,
      'emojis' | 'fields' | 'roles' | 'moved' | 'url' | 'categories'
    >
  > {
  emojis: ImmutableList<CustomEmoji>;
  fields: ImmutableList<AccountField>;
  roles: ImmutableList<AccountRole>;
  categories: ImmutableList<AccountCategory>;
  display_name_html: string;
  note_emojified: string;
  note_plain: string | null;
  hidden: boolean;
  moved: string | null;
  url: string;
  // New boolean flags to indicate the owner's permissions
  can_create_statuses: boolean;
  can_reply_to_statuses: boolean;
  can_reblog_statuses: boolean;
  can_fav_statuses: boolean;
}

export type Account = RecordOf<AccountShape>;

export const accountDefaultValues: AccountShape = {
  acct: '',
  avatar: '',
  avatar_static: '',
  avatar_description: '',
  bot: false,
  created_at: '',
  discoverable: false,
  indexable: false,
  display_name: '',
  display_name_html: '',
  emojis: ImmutableList<CustomEmoji>(),
  feature_approval: {
    automatic: [],
    manual: [],
    current_user: 'missing',
  },
  fields: ImmutableList<AccountField>(),
  group: false,
  header: '',
  header_static: '',
  header_description: '',
  id: '',
  last_status_at: '',
  locked: false,
  noindex: false,
  show_featured: true,
  show_media: true,
  show_media_replies: true,
  note: '',
  note_emojified: '',
  note_plain: 'string',
  roles: ImmutableList<AccountRole>(),
  categories: ImmutableList<AccountCategory>(),
  uri: '',
  url: '',
  username: '',
  followers_count: 0,
  following_count: 0,
  statuses_count: 0,
  hidden: false,
  suspended: false,
  memorial: false,
  limited: false,
  moved: null,
  hide_collections: false,
  email_subscriptions: false,
  // This comes from `ApiMutedAccountJSON`, but we should eventually
  // store that in a different object.
  mute_expires_at: null,
  // Defaults for permission flags
  can_create_statuses: false,
  can_reply_to_statuses: false,
  can_reblog_statuses: false,
  can_fav_statuses: false,
};

const AccountFactory = ImmutableRecord<AccountShape>(accountDefaultValues);

function createAccountField(jsonField: ApiAccountFieldJSON) {
  return AccountFieldFactory({
    ...jsonField,
    name_emojified: escapeTextContentForBrowser(jsonField.name),
    value_emojified: jsonField.value,
    value_plain: unescapeHTML(jsonField.value),
  });
}

export function createAccountFromServerJSON(serverJSON: ApiAccountJSON) {
  const { moved, ...accountJSON } = serverJSON;

  const displayName =
    accountJSON.display_name.trim().length === 0
      ? accountJSON.username
      : accountJSON.display_name;

  const accountNote =
    accountJSON.note && accountJSON.note !== '<p></p>' ? accountJSON.note : '';

  return AccountFactory({
    ...accountJSON,
    moved: moved?.id,
    fields: ImmutableList(
      serverJSON.fields.map((field) => createAccountField(field)),
    ),
    emojis: ImmutableList(
      serverJSON.emojis.map((emoji) => CustomEmojiFactory(emoji)),
    ),
    roles: ImmutableList(
      serverJSON.roles?.map((role) => AccountRoleFactory(role)),
    ),
    categories: mapCategoriesFromJSON(serverJSON),
    display_name_html: escapeTextContentForBrowser(displayName),
    note_emojified: accountNote,
    note_plain: unescapeHTML(accountNote),
    url:
      accountJSON.url?.startsWith('http://') ||
      accountJSON.url?.startsWith('https://')
        ? accountJSON.url
        : accountJSON.uri,
  });
}
