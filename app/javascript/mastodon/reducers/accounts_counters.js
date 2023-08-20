import { Map as ImmutableMap, fromJS } from 'immutable';

import { importAccounts } from 'mastodon/actions/accounts_new';
import { me } from 'mastodon/initial_state';

import {
  ACCOUNT_FOLLOW_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
} from '../actions/accounts';

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
  case importAccounts.type:
    return normalizeAccounts(state, action.payload.accounts);
  case ACCOUNT_FOLLOW_SUCCESS:
    return action.alreadyFollowing ? state :
      incrementFollowers(state, action.relationship.id);
  case ACCOUNT_UNFOLLOW_SUCCESS:
    return decrementFollowers(state, action.relationship.id);
  default:
    return state;
  }
}
