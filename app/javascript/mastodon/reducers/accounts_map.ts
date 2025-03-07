import type { Reducer } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';

import { AxiosError } from 'axios';

import { lookupAccount } from 'mastodon/actions/accounts_typed';
import { importAccounts } from 'mastodon/actions/importer';
import { domain } from 'mastodon/initial_state';

const pattern = new RegExp(`@${domain}$`, 'gi');

export const normalizeForLookup = (str: string) =>
  str.toLowerCase().replace(pattern, '');

const initialState = ImmutableMap<string, string | null>();

export const accountsMapReducer: Reducer<typeof initialState> = (
  state = initialState,
  action,
) => {
  if (lookupAccount.rejected.match(action)) {
    return action.error instanceof AxiosError &&
      action.error.response?.status === 404
      ? state.set(normalizeForLookup(action.meta.arg.acct), null)
      : state;
  } else if (importAccounts.match(action)) {
    return state.withMutations((map) => {
      action.payload.accounts.forEach((account) =>
        map.set(normalizeForLookup(account.acct), account.id),
      );
    });
  } else {
    return state;
  }
};
