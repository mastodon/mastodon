import { Map as ImmutableMap } from 'immutable';

import { ACCOUNT_LOOKUP_FAIL } from '../actions/accounts';
import { importAccounts } from '../actions/accounts_typed';
import { domain } from '../initial_state';

const pattern = new RegExp(`@${domain}$`, 'gi');

export const normalizeForLookup = str =>
  str.toLowerCase().replace(pattern, '');

const initialState = ImmutableMap();

export default function accountsMap(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_LOOKUP_FAIL:
    return action.error?.response?.status === 404 ? state.set(normalizeForLookup(action.acct), null) : state;
  case importAccounts.type:
    return state.withMutations(map => action.payload.accounts.forEach(account => map.set(normalizeForLookup(account.acct), account.id)));
  default:
    return state;
  }
}
