import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from '../actions/importer';
import { Map as ImmutableMap } from 'immutable';

export const normalizeForLookup = str => str.toLowerCase();

const initialState = ImmutableMap();

export default function accountsMap(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_IMPORT:
    return state.set(normalizeForLookup(action.account.acct), action.account.id);
  case ACCOUNTS_IMPORT:
    return state.withMutations(map => action.accounts.forEach(account => map.set(normalizeForLookup(account.acct), account.id)));
  default:
    return state;
  }
};
