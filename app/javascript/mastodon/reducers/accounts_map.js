import { Map as ImmutableMap } from 'immutable';

import { ACCOUNT_LOOKUP_FAIL } from '../actions/accounts';
import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from '../actions/importer';

export const normalizeForLookup = str => str.toLowerCase();

const initialState = ImmutableMap();

export default function accountsMap(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_LOOKUP_FAIL:
    return action.error?.response?.status === 404 ? state.set(normalizeForLookup(action.acct), null) : state;
  case ACCOUNT_IMPORT:
    return state.set(normalizeForLookup(action.account.acct), action.account.id);
  case ACCOUNTS_IMPORT:
    return state.withMutations(map => action.accounts.forEach(account => map.set(normalizeForLookup(account.acct), account.id)));
  default:
    return state;
  }
}
