import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

import {
  expandDirectory,
  fetchDirectory
} from 'mastodon/actions/directory';
import {
  FEATURED_TAGS_FETCH_REQUEST,
  FEATURED_TAGS_FETCH_SUCCESS,
  FEATURED_TAGS_FETCH_FAIL,
} from 'mastodon/actions/featured_tags';

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
  authorizeFollowRequestSuccess,
  rejectFollowRequestSuccess,
} from '../actions/accounts';
import {
  BLOCKS_FETCH_REQUEST,
  BLOCKS_FETCH_SUCCESS,
  BLOCKS_FETCH_FAIL,
  BLOCKS_EXPAND_REQUEST,
  BLOCKS_EXPAND_SUCCESS,
  BLOCKS_EXPAND_FAIL,
} from '../actions/blocks';
import {
  REBLOGS_FETCH_REQUEST,
  REBLOGS_FETCH_SUCCESS,
  REBLOGS_FETCH_FAIL,
  REBLOGS_EXPAND_REQUEST,
  REBLOGS_EXPAND_SUCCESS,
  REBLOGS_EXPAND_FAIL,
  FAVOURITES_FETCH_REQUEST,
  FAVOURITES_FETCH_SUCCESS,
  FAVOURITES_FETCH_FAIL,
  FAVOURITES_EXPAND_REQUEST,
  FAVOURITES_EXPAND_SUCCESS,
  FAVOURITES_EXPAND_FAIL,
} from '../actions/interactions';
import {
  MUTES_FETCH_REQUEST,
  MUTES_FETCH_SUCCESS,
  MUTES_FETCH_FAIL,
  MUTES_EXPAND_REQUEST,
  MUTES_EXPAND_SUCCESS,
  MUTES_EXPAND_FAIL,
} from '../actions/mutes';
import { notificationsUpdate } from '../actions/notifications';

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

/** @type {import('@reduxjs/toolkit').Reducer<typeof initialState>} */
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
    return normalizeList(state, ['reblogged_by', action.id], action.accounts, action.next);
  case REBLOGS_EXPAND_SUCCESS:
    return appendToList(state, ['reblogged_by', action.id], action.accounts, action.next);
  case REBLOGS_FETCH_REQUEST:
  case REBLOGS_EXPAND_REQUEST:
    return state.setIn(['reblogged_by', action.id, 'isLoading'], true);
  case REBLOGS_FETCH_FAIL:
  case REBLOGS_EXPAND_FAIL:
    return state.setIn(['reblogged_by', action.id, 'isLoading'], false);
  case FAVOURITES_FETCH_SUCCESS:
    return normalizeList(state, ['favourited_by', action.id], action.accounts, action.next);
  case FAVOURITES_EXPAND_SUCCESS:
    return appendToList(state, ['favourited_by', action.id], action.accounts, action.next);
  case FAVOURITES_FETCH_REQUEST:
  case FAVOURITES_EXPAND_REQUEST:
    return state.setIn(['favourited_by', action.id, 'isLoading'], true);
  case FAVOURITES_FETCH_FAIL:
  case FAVOURITES_EXPAND_FAIL:
    return state.setIn(['favourited_by', action.id, 'isLoading'], false);
  case notificationsUpdate.type:
    return action.payload.notification.type === 'follow_request' ? normalizeFollowRequest(state, action.payload.notification) : state;
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
  case authorizeFollowRequestSuccess.type:
  case rejectFollowRequestSuccess.type:
    return state.updateIn(['follow_requests', 'items'], list => list.filterNot(item => item === action.payload.id));
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
  case FEATURED_TAGS_FETCH_SUCCESS:
    return normalizeFeaturedTags(state, ['featured_tags', action.id], action.tags, action.id);
  case FEATURED_TAGS_FETCH_REQUEST:
    return state.setIn(['featured_tags', action.id, 'isLoading'], true);
  case FEATURED_TAGS_FETCH_FAIL:
    return state.setIn(['featured_tags', action.id, 'isLoading'], false);
  default:
    if(fetchDirectory.fulfilled.match(action))
      return normalizeList(state, ['directory'], action.payload.accounts, undefined);
    else if( expandDirectory.fulfilled.match(action))
      return appendToList(state, ['directory'], action.payload.accounts, undefined);
    else if(fetchDirectory.pending.match(action) ||
     expandDirectory.pending.match(action))
      return state.setIn(['directory', 'isLoading'], true);
    else if(fetchDirectory.rejected.match(action) ||
     expandDirectory.rejected.match(action))
      return state.setIn(['directory', 'isLoading'], false);
    else
      return state;
  }
}
