import { Map as ImmutableMap } from 'immutable';

import { ACCOUNT_REVEAL } from 'mastodon/actions/accounts';
import { ACCOUNTS_IMPORT, ACCOUNT_IMPORT } from 'mastodon/actions/importer';
import { Account, createAccountFromServerJSON } from 'mastodon/models/account';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

const initialState = ImmutableMap<string, Account>();

// TODO(trinitroglycerin): Reinstate this function
// const normalizeAccount = (state, account: Account) => {
//   account = { ...account };

//   delete account.followers_count;
//   delete account.following_count;
//   delete account.statuses_count;

//   // TODO(renchap): ensure this behaviour is kept
//   account.hidden = state.getIn([account.id, 'hidden']) === false ? false : account.limited;

//   return state.set(account.id, createAccountFromServerJSON(account));
// };

type Action =
  | { type: typeof ACCOUNT_IMPORT; account: ApiAccountJSON }
  | { type: typeof ACCOUNTS_IMPORT; accounts: ApiAccountJSON[] }
  | { type: typeof ACCOUNT_REVEAL; id: unknown };

export function accountsReducer(state = initialState, action: Action) {
  switch (action.type) {
    case ACCOUNT_IMPORT:
      return state.set(action.account.id, createAccountFromServerJSON(action.account));
    case ACCOUNTS_IMPORT:
      return state.merge(action.accounts.map(createAccountFromServerJSON).map((shape) => [shape.id, shape] as [string, Account]));
    case ACCOUNT_REVEAL:
      return state.setIn([action.id, 'hidden'], false);
    default:
      return state;
  }
}
