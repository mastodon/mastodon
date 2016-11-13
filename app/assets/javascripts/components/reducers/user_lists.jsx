import {
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWERS_EXPAND_SUCCESS,
  FOLLOWING_FETCH_SUCCESS,
  FOLLOWING_EXPAND_SUCCESS
} from '../actions/accounts';
import { SUGGESTIONS_FETCH_SUCCESS } from '../actions/suggestions';
import {
  REBLOGS_FETCH_SUCCESS,
  FAVOURITES_FETCH_SUCCESS
} from '../actions/interactions';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  followers: Immutable.Map(),
  following: Immutable.Map(),
  suggestions: Immutable.List(),
  reblogged_by: Immutable.Map(),
  favourited_by: Immutable.Map()
});

const normalizeList = (state, type, id, accounts, prev) => {
  return state.setIn([type, id], Immutable.Map({
    prev,
    items: Immutable.List(accounts.map(item => item.id))
  }));
};

const appendToList = (state, type, id, accounts, prev) => {
  return state.updateIn([type, id], map => {
    return map.set('prev', prev).update('items', list => list.push(...accounts.map(item => item.id)));
  });
};

export default function userLists(state = initialState, action) {
  switch(action.type) {
    case FOLLOWERS_FETCH_SUCCESS:
      return normalizeList(state, 'followers', action.id, action.accounts, action.prev);
    case FOLLOWERS_EXPAND_SUCCESS:
      return appendToList(state, 'followers', action.id, action.accounts, action.prev);
    case FOLLOWING_FETCH_SUCCESS:
      return normalizeList(state, 'following', action.id, action.accounts, action.prev);
    case FOLLOWING_EXPAND_SUCCESS:
      return appendToList(state, 'following', action.id, action.accounts, action.prev);
    case SUGGESTIONS_FETCH_SUCCESS:
      return state.set('suggestions', Immutable.List(action.accounts.map(item => item.id)));
    case REBLOGS_FETCH_SUCCESS:
      return state.setIn(['reblogged_by', action.id], Immutable.List(action.accounts.map(item => item.id)));
    case FAVOURITES_FETCH_SUCCESS:
      return state.setIn(['favourited_by', action.id], Immutable.List(action.accounts.map(item => item.id)));
    default:
      return state;
  }
};
