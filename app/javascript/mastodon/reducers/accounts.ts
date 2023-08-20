import { Map as ImmutableMap } from 'immutable';

import { importAccounts, revealAccount } from 'mastodon/actions/accounts_new';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type { Account } from 'mastodon/models/account';
import { createAccountFromServerJSON } from 'mastodon/models/account';

const initialState = ImmutableMap<string, Account>();

const normalizeAccount = (
  state: typeof initialState,
  account: ApiAccountJSON,
) => {
  return state.set(
    account.id,
    createAccountFromServerJSON(account).set(
      'hidden',
      state.get(account.id)?.hidden === false
        ? false
        : account.limited || false,
    ),
  );
};

const normalizeAccounts = (
  state: typeof initialState,
  accounts: ApiAccountJSON[],
) => {
  accounts.forEach((account) => {
    state = normalizeAccount(state, account);
  });

  return state;
};

export function accountsReducer(
  state = initialState,
  action: typeof revealAccount,
) {
  if (revealAccount.match(action))
    return state.setIn([action.payload.id, 'hidden'], false);
  else if (importAccounts.match(action))
    return normalizeAccounts(state, action.payload.accounts);
  else return state;
}
