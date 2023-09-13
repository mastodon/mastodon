import { Map as ImmutableMap, OrderedSet as ImmutableOrderedSet, fromJS } from 'immutable';

import {
  COMPOSE_MENTION,
  COMPOSE_REPLY,
  COMPOSE_DIRECT,
} from '../actions/compose';
import {
  SEARCH_CHANGE,
  SEARCH_CLEAR,
  SEARCH_FETCH_REQUEST,
  SEARCH_FETCH_FAIL,
  SEARCH_FETCH_SUCCESS,
  SEARCH_SHOW,
  SEARCH_EXPAND_REQUEST,
  SEARCH_EXPAND_SUCCESS,
  SEARCH_HISTORY_UPDATE,
} from '../actions/search';

const initialState = ImmutableMap({
  value: '',
  submitted: false,
  hidden: false,
  results: ImmutableMap(),
  isLoading: false,
  searchTerm: '',
  type: null,
  recent: ImmutableOrderedSet(),
});

export default function search(state = initialState, action) {
  switch(action.type) {
  case SEARCH_CHANGE:
    return state.set('value', action.value);
  case SEARCH_CLEAR:
    return state.withMutations(map => {
      map.set('value', '');
      map.set('results', ImmutableMap());
      map.set('submitted', false);
      map.set('hidden', false);
      map.set('searchTerm', '');
      map.set('type', null);
    });
  case SEARCH_SHOW:
    return state.set('hidden', false);
  case COMPOSE_REPLY:
  case COMPOSE_MENTION:
  case COMPOSE_DIRECT:
    return state.set('hidden', true);
  case SEARCH_FETCH_REQUEST:
    return state.withMutations(map => {
      map.set('isLoading', true);
      map.set('submitted', true);
      map.set('type', action.searchType);
    });
  case SEARCH_FETCH_FAIL:
    return state.set('isLoading', false);
  case SEARCH_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('results', ImmutableMap({
        accounts: ImmutableOrderedSet(action.results.accounts.map(item => item.id)),
        statuses: ImmutableOrderedSet(action.results.statuses.map(item => item.id)),
        hashtags: ImmutableOrderedSet(fromJS(action.results.hashtags)),
      }));

      map.set('searchTerm', action.searchTerm);
      map.set('type', action.searchType);
      map.set('isLoading', false);
    });
  case SEARCH_EXPAND_REQUEST:
    return state.set('type', action.searchType);
  case SEARCH_EXPAND_SUCCESS:
    const results = action.searchType === 'hashtags' ? ImmutableOrderedSet(fromJS(action.results.hashtags)) : action.results[action.searchType].map(item => item.id);
    return state.updateIn(['results', action.searchType], list => list.union(results));
  case SEARCH_HISTORY_UPDATE:
    return state.set('recent', ImmutableOrderedSet(fromJS(action.recent)));
  default:
    return state;
  }
}
