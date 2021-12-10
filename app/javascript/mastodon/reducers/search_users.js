import {
  SEARCH_USERS_CHANGE,
  SEARCH_USERS_CLEAR,
  SEARCH_USERS_FETCH_SUCCESS,
  SEARCH_USERS_SHOW,
  SEARCH_USERS_EXPAND_SUCCESS,
  LIST_EDITOR_SEARCH_USERS_CLEAR,
} from '../actions/search_users';
import {
  COMPOSE_MENTION,
  COMPOSE_REPLY,
  COMPOSE_DIRECT,
} from '../actions/compose';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

const initialState = ImmutableMap({
  value: '',
  submitted: false,
  hidden: false,
  results: ImmutableMap(),
  searchTerm: '',
});

export default function search_users(state = initialState, action) {
  switch (action.type) {
    case SEARCH_USERS_CHANGE:
      return state.set('value', action.value);
    case SEARCH_USERS_CLEAR:
      return state.withMutations((map) => {
        map.set('value', '');
        map.set('results', ImmutableMap());
        map.set('submitted', false);
        map.set('hidden', false);
      });
    case SEARCH_USERS_SHOW:
      return state.set('hidden', false);
    case COMPOSE_REPLY:
    case COMPOSE_MENTION:
    case COMPOSE_DIRECT:
      return state.set('hidden', true);
    case SEARCH_USERS_FETCH_SUCCESS:
      return state
        .set(
          'results',
          ImmutableMap({
            accounts: ImmutableList(
              action.results.accounts.map((item) => item.id)
            ),
          })
        )
        .set('submitted', true)
        .set('searchTerm', action.searchTerm);
    case SEARCH_USERS_EXPAND_SUCCESS:
      const results = action.results[action.searchType].map((item) => item.id);
      return state.updateIn(['results', action.searchType], (list) =>
        list.concat(results)
      );
    case LIST_EDITOR_SEARCH_USERS_CLEAR:
      return state.withMutations('results', ImmutableMap());
    default:
      return state;
  }
}
