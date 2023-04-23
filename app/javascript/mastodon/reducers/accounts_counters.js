import {
  ACCOUNT_FOLLOW_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
} from '../actions/accounts';
import { ACCOUNT_IMPORT, ACCOUNTS_IMPORT } from '../actions/importer';
import { Map as ImmutableMap, fromJS } from 'immutable';
import { me } from 'mastodon/initial_state';

const normalizeAccount = (state, account) => state.set(account.id, fromJS({
  followers_count: account.followers_count,
  following_count: account.following_count,
  statuses_count: account.statuses_count,
}));

const normalizeAccounts = (state, accounts) => {
  accounts.forEach(account => {
    state = normalizeAccount(state, account);
  });

  return state;
};

const incrementFollowers = (state, accountId) =>
  state.updateIn([accountId, 'followers_count'], num => num + 1)
    .updateIn([me, 'following_count'], num => num + 1);

const decrementFollowers = (state, accountId) =>
  state.updateIn([accountId, 'followers_count'], num => Math.max(0, num - 1))
    .updateIn([me, 'following_count'], num => Math.max(0, num - 1));

const initialState = ImmutableMap();

export default function accountsCounters(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_IMPORT:
    return normalizeAccount(state, action.account);
  case ACCOUNTS_IMPORT:
    return normalizeAccounts(state, action.accounts);
  case ACCOUNT_FOLLOW_SUCCESS:
    return action.alreadyFollowing ? state :
      incrementFollowers(state, action.relationship.id);
  case ACCOUNT_UNFOLLOW_SUCCESS:
    return decrementFollowers(state, action.relationship.id);
  default:
    return state;
  }
}
