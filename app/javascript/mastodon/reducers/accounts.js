import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from '../actions/importer';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap();

const normalizeAccount = (state, account) => {
  account = { ...account };

  delete account.followers_count;
  delete account.following_count;
  delete account.statuses_count;

  return state.set(account.id, fromJS(account));
};

const normalizeAccounts = (state, accounts) => {
  accounts.forEach((account) => {
    state = normalizeAccount(state, account);
  });

  return state;
};

export default function accounts(state = initialState, action) {
  switch (action.type) {
    case ACCOUNT_IMPORT:
      return normalizeAccount(state, action.account);
    case ACCOUNTS_IMPORT:
      return normalizeAccounts(state, action.accounts);
    default:
      return state;
  }
}
