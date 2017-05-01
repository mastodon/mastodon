import {
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWERS_EXPAND_SUCCESS,
  FOLLOWING_FETCH_SUCCESS,
  FOLLOWING_EXPAND_SUCCESS,
  FOLLOW_REQUESTS_FETCH_SUCCESS,
  FOLLOW_REQUESTS_EXPAND_SUCCESS,
  FOLLOW_REQUEST_AUTHORIZE_SUCCESS,
  FOLLOW_REQUEST_REJECT_SUCCESS
} from '../actions/accounts';
import {
  REBLOGS_FETCH_SUCCESS,
  FAVOURITES_FETCH_SUCCESS
} from '../actions/interactions';
import {
  BLOCKS_FETCH_SUCCESS,
  BLOCKS_EXPAND_SUCCESS
} from '../actions/blocks';
import {
  MUTES_FETCH_SUCCESS,
  MUTES_EXPAND_SUCCESS
} from '../actions/mutes';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  followers: Immutable.Map(),
  following: Immutable.Map(),
  reblogged_by: Immutable.Map(),
  favourited_by: Immutable.Map(),
  follow_requests: Immutable.Map(),
  blocks: Immutable.Map(),
  mutes: Immutable.Map()
});

const normalizeList = (state, type, id, accounts, next) => {
  return state.setIn([type, id], Immutable.Map({
    next,
    items: Immutable.List(accounts.map(item => item.id))
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
    return state.setIn(['reblogged_by', action.id], Immutable.List(action.accounts.map(item => item.id)));
  case FAVOURITES_FETCH_SUCCESS:
    return state.setIn(['favourited_by', action.id], Immutable.List(action.accounts.map(item => item.id)));
  case FOLLOW_REQUESTS_FETCH_SUCCESS:
    return state.setIn(['follow_requests', 'items'], Immutable.List(action.accounts.map(item => item.id))).setIn(['follow_requests', 'next'], action.next);
  case FOLLOW_REQUESTS_EXPAND_SUCCESS:
    return state.updateIn(['follow_requests', 'items'], list => list.concat(action.accounts.map(item => item.id))).setIn(['follow_requests', 'next'], action.next);
  case FOLLOW_REQUEST_AUTHORIZE_SUCCESS:
  case FOLLOW_REQUEST_REJECT_SUCCESS:
    return state.updateIn(['follow_requests', 'items'], list => list.filterNot(item => item === action.id));
  case BLOCKS_FETCH_SUCCESS:
    return state.setIn(['blocks', 'items'], Immutable.List(action.accounts.map(item => item.id))).setIn(['blocks', 'next'], action.next);
  case BLOCKS_EXPAND_SUCCESS:
    return state.updateIn(['blocks', 'items'], list => list.concat(action.accounts.map(item => item.id))).setIn(['blocks', 'next'], action.next);
  case MUTES_FETCH_SUCCESS:
    return state.setIn(['mutes', 'items'], Immutable.List(action.accounts.map(item => item.id))).setIn(['mutes', 'next'], action.next);
  case MUTES_EXPAND_SUCCESS:
    return state.updateIn(['mutes', 'items'], list => list.concat(action.accounts.map(item => item.id))).setIn(['mutes', 'next'], action.next);
  default:
    return state;
  }
};
