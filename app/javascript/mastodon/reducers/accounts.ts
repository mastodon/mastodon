import { Map as ImmutableMap, fromJS } from 'immutable';

import { ACCOUNT_REVEAL } from 'mastodon/actions/accounts';
import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from 'mastodon/actions/importer';
import type { Account } from 'mastodon/initial_state';

type State = ImmutableMap<string, ImmutableMap<string, unknown>>;
const initialState: State = ImmutableMap();

const normalizeAccount = (state: State, account: Account): State => {
  account = { ...account };

  delete account.followers_count;
  delete account.following_count;
  delete account.statuses_count;

  // TODO(trinitroglycerin): I'm not sure if these sections are needed, the type errors
  // appear to be caused by the fact we're importing types defined in jsdoc.
  //
  // The linter doesn't appear to be "smart" enough to understand these are real types
  // and assumes any symbol imported from `mastodon/initial_state` is `any`.
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
