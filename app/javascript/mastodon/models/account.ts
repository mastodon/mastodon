import type { RecordOf } from 'immutable';
import { List, Record } from 'immutable';

import type {
  ApiAccountFieldJSON,
  ApiAccountRoleJSON,
  ApiAccountJSON,
} from 'mastodon/api_types/accounts';

import { CustomEmojiFactory } from './custom_emoji';
import type { CustomEmoji } from './custom_emoji';

// AccountField
type AccountFieldShape = ApiAccountFieldJSON;
type AccountField = RecordOf<AccountFieldShape>;

const AccountFieldFactory = Record<AccountFieldShape>({
  name: '',
  value: '',
  verified_at: null,
});

// AccountRole
export type AccountRoleShape = ApiAccountRoleJSON;
export type AccountRole = RecordOf<AccountRoleShape>;

const AccountRoleFactory = Record<AccountRoleShape>({
  color: '',
  id: '',
  name: '',
});

export interface AccountRelationship {
  note: string;
}

// Account
export interface AccountShape
  extends Omit<ApiAccountJSON, 'emojis' | 'fields' | 'roles'> {
  emojis: List<CustomEmoji>;
  fields: List<AccountField>;
  roles: List<AccountRole>;
  display_name_html: string;
  note_emojified: string;
  note_plain: string;
  // TODO(renchap): there seem to be other properties used by the code, handle them
  // See https://github.com/mastodon/mastodon/pull/26555/files#diff-95c45eefa511306d2bd9aed0458d8e6e2e1d489a6119ff451f9c8e12a1055f5aR37
  suspended: boolean;
  relationship: AccountRelationship | null;
  hidden: boolean;
  limited: boolean;
  moved: unknown | null;
}

export type Account = RecordOf<AccountShape>;

const AccountFactory = Record<AccountShape>({
  acct: '',
  avatar: '',
  avatar_static: '',
  bot: false,
  created_at: '',
  discoverable: false,
  display_name: '',
  display_name_html: '',
  emojis: List<CustomEmoji>(),
  fields: List<AccountField>(),
  followers_count: 0,
  following_count: 0,
  group: false,
  header: '',
  header_static: '',
  id: '',
  last_status_at: '',
  locked: false,
  noindex: false,
  note: '',
  note_emojified: '',
  note_plain: 'string',
  roles: List<AccountRole>(),
  statuses_count: 0,
  uri: '',
  url: '',
  username: '',
  // TODO(trinitroglycerin): Dummy property implementations to satisfy existing code
  relationship: null,
  hidden: false,
  limited: false,
  suspended: false,
  moved: null
});

export function createAccountFromServerJSON(serverJSON: ApiAccountJSON) {
  // TODO(renchap): the additional fields (note_emojified, note_plain, display_name_html) should be processed here, not in actions/importer/normalizer
  return AccountFactory({
    ...serverJSON,
    fields: List(
      serverJSON.fields.map((fields) => AccountFieldFactory(fields)),
    ),
    emojis: List(serverJSON.emojis.map((emoji) => CustomEmojiFactory(emoji))),
    roles: List(serverJSON.roles.map((role) => AccountRoleFactory(role))),
  });
}
