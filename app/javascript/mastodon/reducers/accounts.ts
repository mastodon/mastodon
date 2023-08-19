import { Map as ImmutableMap, fromJS } from 'immutable';

import { ACCOUNT_REVEAL } from 'mastodon/actions/accounts';
import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from 'mastodon/actions/importer';
import type { AccountField, Emoji } from 'mastodon/initial_state';

export interface Account {
  acct: string;
  avatar: string;
  avatar_static: string;
  bot: boolean;
  created_at: string;
  discoverable: boolean;
  display_name: string;
  emojis: Emoji[];
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

  // TODO(trinitroglycerin): This property is provided by Redux.
  hidden: boolean;
  // TODO(trinitroglycerin): This is a derived property provided by Redux.
  limited: boolean;
}

// TODO(trinitroglycerin): the value of this map is actually a record type,
// mapping keys of Account to those values in an immutable map.
type State = ImmutableMap<string, TypeSafeImmutableMap<Account>>;

// TODO(trinitroglycerin): Temporary type to help aid in type safety.
//
// TypeSafeImmutableMap is an immutable map whose get() function is correctly typed for any type of T,
// where T is an object.
//
// This prevents us having to pass around ImmutableMap everywhere.
export interface TypeSafeImmutableMap<T extends object>
  extends ImmutableMap<keyof T, unknown> {
  get<K extends keyof T, V extends T[K] | null | undefined = undefined>(
    key: K,
    notSetValue?: V
  ): V;
}

const initialState: State = ImmutableMap();

interface Counters {
  followers_count: number;
  following_count: number;
  statuses_count: number;
}

const normalizeAccount = (state: State, account: Account): State => {
  // This type hack is required to allow us to remove the derived counters from Account;
  // React requires that properties deleted in type T are optional on that type.
  // To accomplish this we reconstruct Account, excluding all properties in Counters, and then re-add them as optional.
  const acct = { ...account } as Pick<
    Account,
    Exclude<keyof Account, keyof Counters>
  > &
    Partial<Counters>;

  delete acct.followers_count;
  delete acct.following_count;
  delete acct.statuses_count;

  const limited = acct.limited ?? false;
  const hidden = state.getIn([acct.id, 'hidden']) as boolean;
  acct.hidden = hidden === false ? false : limited;

  return state.set(acct.id, fromJS(acct));
};

const normalizeAccounts = (state: State, accounts: Account[]): State => {
  accounts.forEach((account) => {
    state = normalizeAccount(state, account);
  });

  return state;
};

type Action =
  | { type: typeof ACCOUNT_IMPORT; account: Account }
  | { type: typeof ACCOUNTS_IMPORT; accounts: Account[] }
  | { type: typeof ACCOUNT_REVEAL; id: unknown };

export function accounts(state = initialState, action: Action) {
  switch (action.type) {
    case ACCOUNT_IMPORT:
      return normalizeAccount(state, action.account);
    case ACCOUNTS_IMPORT:
      return normalizeAccounts(state, action.accounts);
    case ACCOUNT_REVEAL:
      return state.setIn([action.id, 'hidden'], false);
    default:
      return state;
  }
}
