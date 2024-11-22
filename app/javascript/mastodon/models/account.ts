import type { RecordOf } from 'immutable';
import { List as ImmutableList, Record as ImmutableRecord } from 'immutable';

import escapeTextContentForBrowser from 'escape-html';

import type {
  ApiAccountFieldJSON,
  ApiAccountRoleJSON,
  ApiAccountJSON,
} from 'mastodon/api_types/accounts';
import type { ApiCustomEmojiJSON } from 'mastodon/api_types/custom_emoji';
import emojify from 'mastodon/features/emoji/emoji';
import { unescapeHTML } from 'mastodon/utils/html';

import { CustomEmojiFactory } from './custom_emoji';
import type { CustomEmoji } from './custom_emoji';

// AccountField
interface AccountFieldShape extends Required<ApiAccountFieldJSON> {
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
    Omit<ApiAccountJSON, 'emojis' | 'fields' | 'roles' | 'moved'>
  > {
  emojis: ImmutableList<CustomEmoji>;
  fields: ImmutableList<AccountField>;
  roles: ImmutableList<AccountRole>;
  display_name_html: string;
  note_emojified: string;
  note_plain: string | null;
  hidden: boolean;
  moved: string | null;
}

export type Account = RecordOf<AccountShape>;

export const accountDefaultValues: AccountShape = {
  acct: '',
  avatar: '',
  avatar_static: '',
  bot: false,
  created_at: '',
  discoverable: false,
  indexable: false,
  display_name: '',
  display_name_html: '',
  emojis: ImmutableList<CustomEmoji>(),
  fields: ImmutableList<AccountField>(),
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
  roles: ImmutableList<AccountRole>(),
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
  // This comes from `ApiMutedAccountJSON`, but we should eventually
  // store that in a different object.
  mute_expires_at: null,
};

const AccountFactory = ImmutableRecord<AccountShape>(accountDefaultValues);

type EmojiMap = Record<string, ApiCustomEmojiJSON>;

function makeEmojiMap(emojis: ApiCustomEmojiJSON[]) {
  return emojis.reduce<EmojiMap>((obj, emoji) => {
    obj[`:${emoji.shortcode}:`] = emoji;
    return obj;
  }, {});
}

function createAccountField(
  jsonField: ApiAccountFieldJSON,
  emojiMap: EmojiMap,
) {
  return AccountFieldFactory({
    ...jsonField,
    name_emojified: emojify(
      escapeTextContentForBrowser(jsonField.name),
      emojiMap,
    ),
    value_emojified: emojify(jsonField.value, emojiMap),
    value_plain: unescapeHTML(jsonField.value),
  });
}

export function createAccountFromServerJSON(serverJSON: ApiAccountJSON) {
  const { moved, ...accountJSON } = serverJSON;

  const emojiMap = makeEmojiMap(accountJSON.emojis);

  const displayName =
    accountJSON.display_name.trim().length === 0
      ? accountJSON.username
      : accountJSON.display_name;

  return AccountFactory({
    ...accountJSON,
    moved: moved?.id,
    fields: ImmutableList(
      serverJSON.fields.map((field) => createAccountField(field, emojiMap)),
    ),
    emojis: ImmutableList(
      serverJSON.emojis.map((emoji) => CustomEmojiFactory(emoji)),
    ),
    roles: ImmutableList(
      serverJSON.roles?.map((role) => AccountRoleFactory(role)),
    ),
    display_name_html: emojify(
      escapeTextContentForBrowser(displayName),
      emojiMap,
    ),
    note_emojified: emojify(accountJSON.note, emojiMap),
    note_plain: unescapeHTML(accountJSON.note),
  });
}
