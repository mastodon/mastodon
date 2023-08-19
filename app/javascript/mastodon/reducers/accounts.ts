import { Map as ImmutableMap, fromJS } from 'immutable';

import { ACCOUNT_REVEAL } from 'mastodon/actions/accounts';
import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from 'mastodon/actions/importer';

type State = ImmutableMap<string, ImmutableMap<string, unknown>>;
const initialState: State = ImmutableMap();

interface Account {
  id: string;
  followers_count?: number;
  following_count?: number;
  statuses_count?: number;
  hidden: boolean;
  limited: boolean;
}

const normalizeAccount = (state: State, account: Account): State => {
  account = { ...account };

  delete account.followers_count;
  delete account.following_count;
  delete account.statuses_count;

  account.hidden =
    state.getIn([account.id, 'hidden']) === false ? false : account.limited;

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

export default function accounts(state = initialState, action: Action) {
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
