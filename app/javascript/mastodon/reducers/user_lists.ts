import { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import {
  DIRECTORY_EXPAND_FAIL,
  DIRECTORY_EXPAND_REQUEST,
  DIRECTORY_EXPAND_SUCCESS,
  DIRECTORY_FETCH_FAIL,
  DIRECTORY_FETCH_REQUEST,
  DIRECTORY_FETCH_SUCCESS,
} from 'mastodon/actions/directory';
import {
  FEATURED_TAGS_FETCH_FAIL,
  FEATURED_TAGS_FETCH_REQUEST,
  FEATURED_TAGS_FETCH_SUCCESS,
} from 'mastodon/actions/featured_tags';
import type { Account } from 'mastodon/models/account';
import type { RootState } from 'mastodon/store';
import { intoTypeSafeImmutableMap } from 'mastodon/utils/immutable';
import type { Map as TypeSafeImmutableMap } from 'mastodon/utils/immutable';

import {
  FOLLOWERS_EXPAND_FAIL,
  FOLLOWERS_EXPAND_REQUEST,
  FOLLOWERS_EXPAND_SUCCESS,
  FOLLOWERS_FETCH_FAIL,
  FOLLOWERS_FETCH_REQUEST,
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWING_EXPAND_FAIL,
  FOLLOWING_EXPAND_REQUEST,
  FOLLOWING_EXPAND_SUCCESS,
  FOLLOWING_FETCH_FAIL,
  FOLLOWING_FETCH_REQUEST,
  FOLLOWING_FETCH_SUCCESS,
  FOLLOW_REQUESTS_EXPAND_FAIL,
  FOLLOW_REQUESTS_EXPAND_REQUEST,
  FOLLOW_REQUESTS_EXPAND_SUCCESS,
  FOLLOW_REQUESTS_FETCH_FAIL,
  FOLLOW_REQUESTS_FETCH_REQUEST,
  FOLLOW_REQUESTS_FETCH_SUCCESS,
  FOLLOW_REQUEST_AUTHORIZE_SUCCESS,
  FOLLOW_REQUEST_REJECT_SUCCESS,
} from '../actions/accounts';
import {
  BLOCKS_EXPAND_FAIL,
  BLOCKS_EXPAND_REQUEST,
  BLOCKS_EXPAND_SUCCESS,
  BLOCKS_FETCH_FAIL,
  BLOCKS_FETCH_REQUEST,
  BLOCKS_FETCH_SUCCESS,
} from '../actions/blocks';
import {
  FAVOURITES_FETCH_SUCCESS,
  REBLOGS_FETCH_SUCCESS,
} from '../actions/interactions';
import {
  MUTES_EXPAND_FAIL,
  MUTES_EXPAND_REQUEST,
  MUTES_EXPAND_SUCCESS,
  MUTES_FETCH_FAIL,
  MUTES_FETCH_REQUEST,
  MUTES_FETCH_SUCCESS,
} from '../actions/mutes';
import { NOTIFICATIONS_UPDATE } from '../actions/notifications';

interface ListInfo {
  next: unknown;
  isLoading: boolean;
  items: ImmutableList<string>;
}

interface Notification {
  account: {
    id: string;
  };
  type: string;
}

const initialListState = intoTypeSafeImmutableMap<ListInfo>({
  next: null,
  isLoading: false,
  items: ImmutableList(),
});

const initialState = ImmutableMap({
  followers: initialListState,
  following: initialListState,
  reblogged_by: initialListState,
  favourited_by: initialListState,
  follow_requests: initialListState,
  blocks: initialListState,
  mutes: initialListState,
  featured_tags: initialListState,
});

type State = typeof initialState;

const normalizeList = (
  state: State,
  path: string[],
  accounts: Account[],
  next: unknown,
): State => {
  return state.setIn(
    path,
    ImmutableMap({
      next,
      items: ImmutableList(accounts.map((item) => item.id)),
      isLoading: false,
    }),
  );
};

function updateListInfo(
  map: TypeSafeImmutableMap<ListInfo>,
  accounts: Account[],
  next: unknown,
): TypeSafeImmutableMap<ListInfo> {
  return map
    .set('next', next)
    .set('isLoading', false)
    .update('items', (list) => list.concat(accounts.map((item) => item.id)));
}

const appendToList = (
  state: State,
  path: string[],
  accounts: Account[],
  next: unknown,
): State => {
  return state.updateIn(path, (map) => {
    return updateListInfo(
      map as TypeSafeImmutableMap<ListInfo>,
      accounts,
      next,
    );
  });
};

const normalizeFollowRequest = (
  state: State,
  notification: Notification,
): State => {
  return state.updateIn(['follow_requests', 'items'], (list) => {
    const list2 = list as ImmutableList<string>;
    return list2
      .filterNot((item) => item === notification.account.id)
      .unshift(notification.account.id);
  });
};

export interface FeaturedTag {
  name: string;
  statuses_count: number;
  last_status_at: string;
}

const normalizeFeaturedTag = (
  featuredTags: FeaturedTag,
  accountId: string,
): TypeSafeImmutableMap<FeaturedTag & { accountId: string }> => {
  const normalizeFeaturedTag = { ...featuredTags, accountId: accountId };
  return intoTypeSafeImmutableMap(normalizeFeaturedTag);
};

const normalizeFeaturedTags = (
  state: State,
  path: string[],
  featuredTags: FeaturedTag[],
  accountId: string,
) => {
  return state.setIn(
    path,
    ImmutableMap({
      items: ImmutableList(
        featuredTags
          .map((featuredTag) => normalizeFeaturedTag(featuredTag, accountId))
          .sort((a, b) => b.get('statuses_count') - a.get('statuses_count')),
      ),
      isLoading: false,
    }),
  );
};

export function selectFeaturedTags(accountId: string) {
  return (
    state: RootState,
  ): ImmutableList<TypeSafeImmutableMap<FeaturedTag>> => {
    return state.user_lists.getIn(
      ['featured_tags', accountId, 'items'],
      ImmutableList(),
    ) as ImmutableList<TypeSafeImmutableMap<FeaturedTag>>;
  };
}

// The following types describe actions that are homogenous.
type SuccessActionKey =
  | typeof FOLLOWERS_FETCH_SUCCESS
  | typeof FOLLOWERS_EXPAND_SUCCESS
  | typeof FOLLOWING_FETCH_SUCCESS
  | typeof FOLLOWING_EXPAND_SUCCESS
  | typeof REBLOGS_FETCH_SUCCESS
  | typeof FAVOURITES_FETCH_SUCCESS
  | typeof FOLLOW_REQUESTS_FETCH_SUCCESS
  | typeof FOLLOW_REQUESTS_EXPAND_SUCCESS
  | typeof FOLLOW_REQUEST_AUTHORIZE_SUCCESS
  | typeof FOLLOW_REQUEST_REJECT_SUCCESS
  | typeof BLOCKS_FETCH_SUCCESS
  | typeof BLOCKS_EXPAND_SUCCESS
  | typeof MUTES_FETCH_SUCCESS
  | typeof MUTES_EXPAND_SUCCESS
  | typeof DIRECTORY_FETCH_SUCCESS
  | typeof DIRECTORY_EXPAND_SUCCESS;

interface SuccessAction {
  type: SuccessActionKey;
  id: string;
  accounts: Account[];
  next: unknown;
}

type RequestActionKey =
  | typeof DIRECTORY_FETCH_REQUEST
  | typeof DIRECTORY_EXPAND_REQUEST
  | typeof FEATURED_TAGS_FETCH_REQUEST
  | typeof FOLLOWERS_FETCH_REQUEST
  | typeof FOLLOWERS_EXPAND_REQUEST
  | typeof FOLLOWING_FETCH_REQUEST
  | typeof FOLLOWING_EXPAND_REQUEST
  | typeof FOLLOW_REQUESTS_FETCH_REQUEST
  | typeof FOLLOW_REQUESTS_EXPAND_REQUEST
  | typeof BLOCKS_FETCH_REQUEST
  | typeof BLOCKS_EXPAND_REQUEST
  | typeof MUTES_FETCH_REQUEST
  | typeof MUTES_EXPAND_REQUEST;

interface RequestAction {
  type: RequestActionKey;
  id: string;
}

type FailActionKey =
  | typeof DIRECTORY_FETCH_FAIL
  | typeof DIRECTORY_EXPAND_FAIL
  | typeof FEATURED_TAGS_FETCH_FAIL
  | typeof FOLLOWERS_FETCH_FAIL
  | typeof FOLLOWERS_EXPAND_FAIL
  | typeof FOLLOWING_FETCH_FAIL
  | typeof FOLLOWING_EXPAND_FAIL
  | typeof FOLLOW_REQUESTS_FETCH_FAIL
  | typeof FOLLOW_REQUESTS_EXPAND_FAIL
  | typeof BLOCKS_FETCH_FAIL
  | typeof BLOCKS_EXPAND_FAIL
  | typeof MUTES_FETCH_FAIL
  | typeof MUTES_EXPAND_FAIL;

interface FailAction {
  type: FailActionKey;
  id: string;
}

// Some actions have unique properties. They're listed below.
interface FeaturedTagsFetchSuccessAction {
  type: typeof FEATURED_TAGS_FETCH_SUCCESS;
  id: string;
  tags: FeaturedTag[];
}

interface NotificationUpdateAction {
  type: typeof NOTIFICATIONS_UPDATE;
  notification: Notification;
}

type Action =
  | SuccessAction
  | RequestAction
  | FailAction
  | NotificationUpdateAction
  | FeaturedTagsFetchSuccessAction;

export function userListsReducer(state = initialState, action: Action) {
  switch (action.type) {
    case FOLLOWERS_FETCH_SUCCESS:
      return normalizeList(
        state,
        ['followers', action.id],
        action.accounts,
        action.next,
      );
    case FOLLOWERS_EXPAND_SUCCESS:
      return appendToList(
        state,
        ['followers', action.id],
        action.accounts,
        action.next,
      );
    case FOLLOWERS_FETCH_REQUEST:
    case FOLLOWERS_EXPAND_REQUEST:
      return state.setIn(['followers', action.id, 'isLoading'], true);
    case FOLLOWERS_FETCH_FAIL:
    case FOLLOWERS_EXPAND_FAIL:
      return state.setIn(['followers', action.id, 'isLoading'], false);
    case FOLLOWING_FETCH_SUCCESS:
      return normalizeList(
        state,
        ['following', action.id],
        action.accounts,
        action.next,
      );
    case FOLLOWING_EXPAND_SUCCESS:
      return appendToList(
        state,
        ['following', action.id],
        action.accounts,
        action.next,
      );
    case FOLLOWING_FETCH_REQUEST:
    case FOLLOWING_EXPAND_REQUEST:
      return state.setIn(['following', action.id, 'isLoading'], true);
    case FOLLOWING_FETCH_FAIL:
    case FOLLOWING_EXPAND_FAIL:
      return state.setIn(['following', action.id, 'isLoading'], false);
    case REBLOGS_FETCH_SUCCESS:
      return state.setIn(
        ['reblogged_by', action.id],
        ImmutableList(action.accounts.map((item) => item.id)),
      );
    case FAVOURITES_FETCH_SUCCESS:
      return state.setIn(
        ['favourited_by', action.id],
        ImmutableList(action.accounts.map((item) => item.id)),
      );
    case NOTIFICATIONS_UPDATE:
      return action.notification.type === 'follow_request'
        ? normalizeFollowRequest(state, action.notification)
        : state;
    case FOLLOW_REQUESTS_FETCH_SUCCESS:
      return normalizeList(
        state,
        ['follow_requests'],
        action.accounts,
        action.next,
      );
    case FOLLOW_REQUESTS_EXPAND_SUCCESS:
      return appendToList(
        state,
        ['follow_requests'],
        action.accounts,
        action.next,
      );
    case FOLLOW_REQUESTS_FETCH_REQUEST:
    case FOLLOW_REQUESTS_EXPAND_REQUEST:
      return state.setIn(['follow_requests', 'isLoading'], true);
    case FOLLOW_REQUESTS_FETCH_FAIL:
    case FOLLOW_REQUESTS_EXPAND_FAIL:
      return state.setIn(['follow_requests', 'isLoading'], false);
    case FOLLOW_REQUEST_AUTHORIZE_SUCCESS:
    case FOLLOW_REQUEST_REJECT_SUCCESS:
      return state.updateIn(['follow_requests', 'items'], (list) => {
        const list2 = list as ImmutableList<string>;
        return list2.filterNot((item) => item === action.id);
      });
    case BLOCKS_FETCH_SUCCESS:
      return normalizeList(state, ['blocks'], action.accounts, action.next);
    case BLOCKS_EXPAND_SUCCESS:
      return appendToList(state, ['blocks'], action.accounts, action.next);
    case BLOCKS_FETCH_REQUEST:
    case BLOCKS_EXPAND_REQUEST:
      return state.setIn(['blocks', 'isLoading'], true);
    case BLOCKS_FETCH_FAIL:
    case BLOCKS_EXPAND_FAIL:
      return state.setIn(['blocks', 'isLoading'], false);
    case MUTES_FETCH_SUCCESS:
      return normalizeList(state, ['mutes'], action.accounts, action.next);
    case MUTES_EXPAND_SUCCESS:
      return appendToList(state, ['mutes'], action.accounts, action.next);
    case MUTES_FETCH_REQUEST:
    case MUTES_EXPAND_REQUEST:
      return state.setIn(['mutes', 'isLoading'], true);
    case MUTES_FETCH_FAIL:
    case MUTES_EXPAND_FAIL:
      return state.setIn(['mutes', 'isLoading'], false);
    case DIRECTORY_FETCH_SUCCESS:
      return normalizeList(state, ['directory'], action.accounts, action.next);
    case DIRECTORY_EXPAND_SUCCESS:
      return appendToList(state, ['directory'], action.accounts, action.next);
    case DIRECTORY_FETCH_REQUEST:
    case DIRECTORY_EXPAND_REQUEST:
      return state.setIn(['directory', 'isLoading'], true);
    case DIRECTORY_FETCH_FAIL:
    case DIRECTORY_EXPAND_FAIL:
      return state.setIn(['directory', 'isLoading'], false);
    case FEATURED_TAGS_FETCH_SUCCESS:
      return normalizeFeaturedTags(
        state,
        ['featured_tags', action.id],
        action.tags,
        action.id,
      );
    case FEATURED_TAGS_FETCH_REQUEST:
      return state.setIn(['featured_tags', action.id, 'isLoading'], true);
    case FEATURED_TAGS_FETCH_FAIL:
      return state.setIn(['featured_tags', action.id, 'isLoading'], false);
    default:
      return state;
  }
}
