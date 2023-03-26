import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from 'mastodon/actions/importer';
import { ACCOUNT_REVEAL, ACCOUNT_FETCH_REQUEST, ACCOUNT_FETCH_SUCCESS, ACCOUNT_FETCH_FAIL } from 'mastodon/actions/accounts';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap();

const normalizeAccount = (state, account) => {
  account = { ...account };

  delete account.followers_count;
  delete account.following_count;
  delete account.statuses_count;

  account.hidden = state.getIn([account.id, 'hidden']) === false ? false : account.limited;

  return state.set(account.id, fromJS(account));
};

const normalizeAccounts = (state, accounts) => {
  accounts.forEach(account => {
    state = normalizeAccount(state, account);
  });

  return state;
};

export default function accounts(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_IMPORT:
    return normalizeAccount(state, action.account);
  case ACCOUNTS_IMPORT:
    return normalizeAccounts(state, action.accounts);
  case ACCOUNT_REVEAL:
    return state.setIn([action.id, 'hidden'], false);
  case ACCOUNT_FETCH_REQUEST:
    return state.set(`${action.id}:isLoading`, true);
  case ACCOUNT_FETCH_SUCCESS:
    return state.set(`${action.id}:isLoading`, false);
  case ACCOUNT_FETCH_FAIL:
    return state.set(`${action.id}:isLoading`, false);
  default:
    return state;
  }
}
