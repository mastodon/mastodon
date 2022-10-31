import {
  NOTIFICATIONS_UPDATE,
} from '../actions/notifications';
import {
  FOLLOWERS_FETCH_REQUEST,
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWERS_FETCH_FAIL,
  FOLLOWERS_EXPAND_REQUEST,
  FOLLOWERS_EXPAND_SUCCESS,
  FOLLOWERS_EXPAND_FAIL,
  FOLLOWING_FETCH_REQUEST,
  FOLLOWING_FETCH_SUCCESS,
  FOLLOWING_FETCH_FAIL,
  FOLLOWING_EXPAND_REQUEST,
  FOLLOWING_EXPAND_SUCCESS,
  FOLLOWING_EXPAND_FAIL,
  FOLLOW_REQUESTS_FETCH_REQUEST,
  FOLLOW_REQUESTS_FETCH_SUCCESS,
  FOLLOW_REQUESTS_FETCH_FAIL,
  FOLLOW_REQUESTS_EXPAND_REQUEST,
  FOLLOW_REQUESTS_EXPAND_SUCCESS,
  FOLLOW_REQUESTS_EXPAND_FAIL,
  FOLLOW_REQUEST_AUTHORIZE_SUCCESS,
  FOLLOW_REQUEST_REJECT_SUCCESS,
} from 'flavours/glitch/actions/accounts';
import {
  REBLOGS_FETCH_SUCCESS,
  FAVOURITES_FETCH_SUCCESS,
} from 'flavours/glitch/actions/interactions';
import {
  BLOCKS_FETCH_REQUEST,
  BLOCKS_FETCH_SUCCESS,
  BLOCKS_FETCH_FAIL,
  BLOCKS_EXPAND_REQUEST,
  BLOCKS_EXPAND_SUCCESS,
  BLOCKS_EXPAND_FAIL,
} from 'flavours/glitch/actions/blocks';
import {
  MUTES_FETCH_REQUEST,
  MUTES_FETCH_SUCCESS,
  MUTES_FETCH_FAIL,
  MUTES_EXPAND_REQUEST,
  MUTES_EXPAND_SUCCESS,
  MUTES_EXPAND_FAIL,
} from 'flavours/glitch/actions/mutes';
import {
  DIRECTORY_FETCH_REQUEST,
  DIRECTORY_FETCH_SUCCESS,
  DIRECTORY_FETCH_FAIL,
  DIRECTORY_EXPAND_REQUEST,
  DIRECTORY_EXPAND_SUCCESS,
  DIRECTORY_EXPAND_FAIL,
} from 'flavours/glitch/actions/directory';
import {
  FEATURED_TAGS_FETCH_REQUEST,
  FEATURED_TAGS_FETCH_SUCCESS,
  FEATURED_TAGS_FETCH_FAIL,
} from 'flavours/glitch/actions/featured_tags';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialListState = ImmutableMap({
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

const normalizeList = (state, path, accounts, next) => {
  return state.setIn(path, ImmutableMap({
    next,
    items: ImmutableList(accounts.map(item => item.id)),
    isLoading: false,
  }));
};

const appendToList = (state, path, accounts, next) => {
  return state.updateIn(path, map => {
    return map.set('next', next).set('isLoading', false).update('items', list => list.concat(accounts.map(item => item.id)));
  });
};

const normalizeFollowRequest = (state, notification) => {
  return state.updateIn(['follow_requests', 'items'], list => {
    return list.filterNot(item => item === notification.account.id).unshift(notification.account.id);
  });
};

const normalizeFeaturedTag = (featuredTags, accountId) => {
  const normalizeFeaturedTag = { ...featuredTags, accountId: accountId };
  return fromJS(normalizeFeaturedTag);
};

const normalizeFeaturedTags = (state, path, featuredTags, accountId) => {
  return state.setIn(path, ImmutableMap({
    items: ImmutableList(featuredTags.map(featuredTag => normalizeFeaturedTag(featuredTag, accountId)).sort((a, b) => b.get('statuses_count') - a.get('statuses_count'))),
    isLoading: false,
  }));
};

export default function userLists(state = initialState, action) {
  switch(action.type) {
  case FOLLOWERS_FETCH_SUCCESS:
    return normalizeList(state, ['followers', action.id], action.accounts, action.next);
  case FOLLOWERS_EXPAND_SUCCESS:
    return appendToList(state, ['followers', action.id], action.accounts, action.next);
  case FOLLOWERS_FETCH_REQUEST:
  case FOLLOWERS_EXPAND_REQUEST:
    return state.setIn(['followers', action.id, 'isLoading'], true);
  case FOLLOWERS_FETCH_FAIL:
  case FOLLOWERS_EXPAND_FAIL:
    return state.setIn(['followers', action.id, 'isLoading'], false);
  case FOLLOWING_FETCH_SUCCESS:
    return normalizeList(state, ['following', action.id], action.accounts, action.next);
  case FOLLOWING_EXPAND_SUCCESS:
    return appendToList(state, ['following', action.id], action.accounts, action.next);
  case FOLLOWING_FETCH_REQUEST:
  case FOLLOWING_EXPAND_REQUEST:
    return state.setIn(['following', action.id, 'isLoading'], true);
  case FOLLOWING_FETCH_FAIL:
  case FOLLOWING_EXPAND_FAIL:
    return state.setIn(['following', action.id, 'isLoading'], false);
  case REBLOGS_FETCH_SUCCESS:
    return state.setIn(['reblogged_by', action.id], ImmutableList(action.accounts.map(item => item.id)));
  case FAVOURITES_FETCH_SUCCESS:
    return state.setIn(['favourited_by', action.id], ImmutableList(action.accounts.map(item => item.id)));
  case NOTIFICATIONS_UPDATE:
    return action.notification.type === 'follow_request' ? normalizeFollowRequest(state, action.notification) : state;
  case FOLLOW_REQUESTS_FETCH_SUCCESS:
    return normalizeList(state, ['follow_requests'], action.accounts, action.next);
  case FOLLOW_REQUESTS_EXPAND_SUCCESS:
    return appendToList(state, ['follow_requests'], action.accounts, action.next);
  case FOLLOW_REQUESTS_FETCH_REQUEST:
  case FOLLOW_REQUESTS_EXPAND_REQUEST:
    return state.setIn(['follow_requests', 'isLoading'], true);
  case FOLLOW_REQUESTS_FETCH_FAIL:
  case FOLLOW_REQUESTS_EXPAND_FAIL:
    return state.setIn(['follow_requests', 'isLoading'], false);
  case FOLLOW_REQUEST_AUTHORIZE_SUCCESS:
  case FOLLOW_REQUEST_REJECT_SUCCESS:
    return state.updateIn(['follow_requests', 'items'], list => list.filterNot(item => item === action.id));
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
    return normalizeFeaturedTags(state, ['featured_tags', action.id], action.tags, action.id);
  case FEATURED_TAGS_FETCH_REQUEST:
    return state.setIn(['featured_tags', action.id, 'isLoading'], true);
  case FEATURED_TAGS_FETCH_FAIL:
    return state.setIn(['featured_tags', action.id, 'isLoading'], false);
  default:
    return state;
  }
};
