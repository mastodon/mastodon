import { Map as ImmutableMap } from 'immutable';

import { ACCOUNT_LOOKUP_FAIL } from '../actions/accounts';
import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from '../actions/importer';

import type { AccountModel } from './accounts';

export const normalizeForLookup = (str: string) => str.toLowerCase();

export const initialState = ImmutableMap<string, string | null>();

type Action =
  | {
      type: typeof ACCOUNT_LOOKUP_FAIL;
      error?: { response?: { status: number } };
      acct: string;
    }
  | { type: typeof ACCOUNT_IMPORT; acct: string; account: AccountModel }
  | { type: typeof ACCOUNTS_IMPORT; accounts: AccountModel[] };

export function accountsMapReducer(state = initialState, action: Action) {
  switch (action.type) {
    case ACCOUNT_LOOKUP_FAIL:
      return action.error?.response?.status === 404
        ? state.set(normalizeForLookup(action.acct), null)
        : state;
    case ACCOUNT_IMPORT:
      return state.set(
        normalizeForLookup(action.account.acct),
        action.account.id
      );
    case ACCOUNTS_IMPORT:
      return state.withMutations((map) =>
        action.accounts.forEach((account) =>
          map.set(normalizeForLookup(account.acct), account.id)
        )
      );
    default:
      return state;
  }
}
