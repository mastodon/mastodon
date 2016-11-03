import {
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWING_FETCH_SUCCESS
} from '../actions/accounts';
import { SUGGESTIONS_FETCH_SUCCESS } from '../actions/suggestions';
import { REBLOGS_FETCH_SUCCESS } from '../actions/interactions';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  followers: Immutable.Map(),
  following: Immutable.Map(),
  suggestions: Immutable.List()
});

export default function userLists(state = initialState, action) {
  switch(action.type) {
    case FOLLOWERS_FETCH_SUCCESS:
      return state.setIn(['followers', action.id], Immutable.List(action.accounts.map(item => item.id)));
    case FOLLOWING_FETCH_SUCCESS:
      return state.setIn(['following', action.id], Immutable.List(action.accounts.map(item => item.id)));
    case SUGGESTIONS_FETCH_SUCCESS:
      return state.set('suggestions', Immutable.List(action.accounts.map(item => item.id)));
    case REBLOGS_FETCH_SUCCESS:
      return state.setIn(['reblogged_by', action.id], Immutable.List(action.accounts.map(item => item.id)));
    default:
      return state;
  }
};
