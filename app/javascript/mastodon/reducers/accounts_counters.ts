import { Map as ImmutableMap, Record } from 'immutable';

import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import { me } from 'mastodon/initial_state';

import {
  ACCOUNT_FOLLOW_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
} from '../actions/accounts';
import { ACCOUNTS_IMPORT, ACCOUNT_IMPORT } from '../actions/importer';

export interface AccountCounters {
  followers_count: number;
  following_count: number;
  statuses_count: number;
}

const CounterFactory = Record<AccountCounters>({
  followers_count: 0,
  following_count: 0,
  statuses_count: 0,
});

type State = ImmutableMap<string, Record<AccountCounters>>;

const normalizeAccount = (state: State, account: ApiAccountJSON): State =>
  state.set(
    account.id,
    CounterFactory({
      followers_count: account.followers_count,
      following_count: account.following_count,
      statuses_count: account.statuses_count,
    }),
  );

const normalizeAccounts = (state: State, accounts: ApiAccountJSON[]): State => {
  accounts.forEach((account) => {
    state = normalizeAccount(state, account);
  });

  return state;
};

const incrementFollowers = (state: State, accountId: string): State =>
  state
    .updateIn([accountId, 'followers_count'], (num) => (num as number) + 1)
    .updateIn([me, 'following_count'], (num) => (num as number) + 1);

const decrementFollowers = (state: State, accountId: string): State =>
  state
    .updateIn([accountId, 'followers_count'], (num) =>
      Math.max(0, (num as number) - 1),
    )
    .updateIn([me, 'following_count'], (num) =>
      Math.max(0, (num as number) - 1),
    );

const initialState: State = ImmutableMap();

type Action =
  | {
      type: typeof ACCOUNT_FOLLOW_SUCCESS;
      alreadyFollowing: boolean;
      relationship: { id: string };
    }
  | {
      type: typeof ACCOUNT_UNFOLLOW_SUCCESS;
      relationship: { id: string };
    }
  | { type: typeof ACCOUNT_IMPORT; account: ApiAccountJSON }
  | { type: typeof ACCOUNTS_IMPORT; accounts: ApiAccountJSON[] };

export function accountsCountersReducer(
  state: State = initialState,
  action: Action,
): State {
  switch (action.type) {
    case ACCOUNT_IMPORT:
      return normalizeAccount(state, action.account);
    case ACCOUNTS_IMPORT:
      return normalizeAccounts(state, action.accounts);
    case ACCOUNT_FOLLOW_SUCCESS:
      return action.alreadyFollowing
        ? state
        : incrementFollowers(state, action.relationship.id);
    case ACCOUNT_UNFOLLOW_SUCCESS:
      return decrementFollowers(state, action.relationship.id);
    default:
      return state;
  }
}
