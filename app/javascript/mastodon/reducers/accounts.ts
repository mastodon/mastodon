import { Map as ImmutableMap, fromJS } from 'immutable';

import { ACCOUNT_REVEAL } from 'mastodon/actions/accounts';
import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from 'mastodon/actions/importer';
import type { Account as StateAccount } from 'mastodon/initial_state';

// TODO(trinitroglycerin): the value of this map is actually a record type,
// mapping keys of Account to those values in an immutable map.
type State = ImmutableMap<string, ImmutableMap<string, unknown>>;
const initialState: State = ImmutableMap();

interface Status {
  limited: boolean;
  hidden: boolean;
}

interface Counters {
  followers_count: number;
  following_count: number;
  statuses_count: number;
}

// This complicated type is used to allow for the deletion of the properties in Counters from the Account type.
//
// The properties in the Counters type are derived values and are tracked in the account_counters slice.
//
// TODO(trinitroglycerin): This additionally adds the derived hidden and limited properties, as these are not present
// in the jsdoc types. However, there are a few instances where React components rely on these properties existing,
// so it's possible that the hidden and limited properties should be graduated to the jsdoc types.
type Account = Pick<StateAccount, Exclude<keyof StateAccount, keyof Counters>> &
  Partial<Counters> &
  Status;

const normalizeAccount = (state: State, account: Account): State => {
  account = { ...account };
  // The following properties are deleted from the account as they are tracked separately within a the account_counters slice.
  delete account.followers_count;
  delete account.following_count;
  delete account.statuses_count;

  const limited = account.limited ?? false;
  const hidden = state.getIn([account.id, 'hidden']) as boolean;
  account.hidden = hidden === false ? false : limited;

  return state.set(account.id, fromJS(account));
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
