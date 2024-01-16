import type { Reducer } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';

import {
  followAccountSuccess,
  unfollowAccountSuccess,
  importAccounts,
  revealAccount,
} from 'flavours/glitch/actions/accounts_typed';
import type { ApiAccountJSON } from 'flavours/glitch/api_types/accounts';
import { me } from 'flavours/glitch/initial_state';
import type { Account } from 'flavours/glitch/models/account';
import { createAccountFromServerJSON } from 'flavours/glitch/models/account';

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

function getCurrentUser() {
  if (!me)
    throw new Error(
      'No current user (me) defined when calling `accountsReducer`',
    );

  return me;
}

export const accountsReducer: Reducer<typeof initialState> = (
  state = initialState,
  action,
) => {
  if (revealAccount.match(action))
    return state.setIn([action.payload.id, 'hidden'], false);
  else if (importAccounts.match(action))
    return normalizeAccounts(state, action.payload.accounts);
  else if (followAccountSuccess.match(action)) {
    return state
      .update(action.payload.relationship.id, (account) =>
        account?.update('followers_count', (n) => n + 1),
      )
      .update(getCurrentUser(), (account) =>
        account?.update('following_count', (n) => n + 1),
      );
  } else if (unfollowAccountSuccess.match(action))
    return state
      .update(action.payload.relationship.id, (account) =>
        account?.update('followers_count', (n) => Math.max(0, n - 1)),
      )
      .update(getCurrentUser(), (account) =>
        account?.update('following_count', (n) => Math.max(0, n - 1)),
      );
  else return state;
};
