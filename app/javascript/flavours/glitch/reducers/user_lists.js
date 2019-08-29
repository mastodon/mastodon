import {
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWERS_EXPAND_SUCCESS,
  FOLLOWING_FETCH_SUCCESS,
  FOLLOWING_EXPAND_SUCCESS,
  FOLLOW_REQUESTS_FETCH_SUCCESS,
  FOLLOW_REQUESTS_EXPAND_SUCCESS,
  FOLLOW_REQUEST_AUTHORIZE_SUCCESS,
  FOLLOW_REQUEST_REJECT_SUCCESS,
} from 'flavours/glitch/actions/accounts';
import {
  REBLOGS_FETCH_SUCCESS,
  FAVOURITES_FETCH_SUCCESS,
} from 'flavours/glitch/actions/interactions';
import {
  BLOCKS_FETCH_SUCCESS,
  BLOCKS_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/blocks';
import {
  MUTES_FETCH_SUCCESS,
  MUTES_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/mutes';
import {
  DIRECTORY_FETCH_REQUEST,
  DIRECTORY_FETCH_SUCCESS,
  DIRECTORY_FETCH_FAIL,
  DIRECTORY_EXPAND_REQUEST,
  DIRECTORY_EXPAND_SUCCESS,
  DIRECTORY_EXPAND_FAIL,
} from 'flavours/glitch/actions/directory';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

const initialState = ImmutableMap({
  followers: ImmutableMap(),
  following: ImmutableMap(),
  reblogged_by: ImmutableMap(),
  favourited_by: ImmutableMap(),
  follow_requests: ImmutableMap(),
  blocks: ImmutableMap(),
  mutes: ImmutableMap(),
});

const normalizeList = (state, type, id, accounts, next) => {
  return state.setIn([type, id], ImmutableMap({
    next,
    items: ImmutableList(accounts.map(item => item.id)),
  }));
};

const appendToList = (state, type, id, accounts, next) => {
  return state.updateIn([type, id], map => {
    return map.set('next', next).update('items', list => list.concat(accounts.map(item => item.id)));
  });
};

export default function userLists(state = initialState, action) {
  switch(action.type) {
  case FOLLOWERS_FETCH_SUCCESS:
    return normalizeList(state, 'followers', action.id, action.accounts, action.next);
  case FOLLOWERS_EXPAND_SUCCESS:
    return appendToList(state, 'followers', action.id, action.accounts, action.next);
  case FOLLOWING_FETCH_SUCCESS:
    return normalizeList(state, 'following', action.id, action.accounts, action.next);
  case FOLLOWING_EXPAND_SUCCESS:
    return appendToList(state, 'following', action.id, action.accounts, action.next);
  case REBLOGS_FETCH_SUCCESS:
    return state.setIn(['reblogged_by', action.id], ImmutableList(action.accounts.map(item => item.id)));
  case FAVOURITES_FETCH_SUCCESS:
    return state.setIn(['favourited_by', action.id], ImmutableList(action.accounts.map(item => item.id)));
  case FOLLOW_REQUESTS_FETCH_SUCCESS:
    return state.setIn(['follow_requests', 'items'], ImmutableList(action.accounts.map(item => item.id))).setIn(['follow_requests', 'next'], action.next);
  case FOLLOW_REQUESTS_EXPAND_SUCCESS:
    return state.updateIn(['follow_requests', 'items'], list => list.concat(action.accounts.map(item => item.id))).setIn(['follow_requests', 'next'], action.next);
  case FOLLOW_REQUEST_AUTHORIZE_SUCCESS:
  case FOLLOW_REQUEST_REJECT_SUCCESS:
    return state.updateIn(['follow_requests', 'items'], list => list.filterNot(item => item === action.id));
  case BLOCKS_FETCH_SUCCESS:
    return state.setIn(['blocks', 'items'], ImmutableList(action.accounts.map(item => item.id))).setIn(['blocks', 'next'], action.next);
  case BLOCKS_EXPAND_SUCCESS:
    return state.updateIn(['blocks', 'items'], list => list.concat(action.accounts.map(item => item.id))).setIn(['blocks', 'next'], action.next);
  case MUTES_FETCH_SUCCESS:
    return state.setIn(['mutes', 'items'], ImmutableList(action.accounts.map(item => item.id))).setIn(['mutes', 'next'], action.next);
  case MUTES_EXPAND_SUCCESS:
    return state.updateIn(['mutes', 'items'], list => list.concat(action.accounts.map(item => item.id))).setIn(['mutes', 'next'], action.next);
  case DIRECTORY_FETCH_SUCCESS:
    return state.setIn(['directory', 'items'], ImmutableList(action.accounts.map(item => item.id))).setIn(['directory', 'isLoading'], false);
  case DIRECTORY_EXPAND_SUCCESS:
    return state.updateIn(['directory', 'items'], list => list.concat(action.accounts.map(item => item.id))).setIn(['directory', 'isLoading'], false);
  case DIRECTORY_FETCH_REQUEST:
  case DIRECTORY_EXPAND_REQUEST:
    return state.setIn(['directory', 'isLoading'], true);
  case DIRECTORY_FETCH_FAIL:
  case DIRECTORY_EXPAND_FAIL:
    return state.setIn(['directory', 'isLoading'], false);
  default:
    return state;
  }
};
