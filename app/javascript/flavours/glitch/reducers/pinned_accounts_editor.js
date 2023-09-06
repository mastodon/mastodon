import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import {
  PINNED_ACCOUNTS_EDITOR_RESET,
  PINNED_ACCOUNTS_FETCH_REQUEST,
  PINNED_ACCOUNTS_FETCH_SUCCESS,
  PINNED_ACCOUNTS_FETCH_FAIL,
  PINNED_ACCOUNTS_SUGGESTIONS_FETCH_SUCCESS,
  PINNED_ACCOUNTS_EDITOR_SUGGESTIONS_CLEAR,
  PINNED_ACCOUNTS_EDITOR_SUGGESTIONS_CHANGE,
  ACCOUNT_PIN_SUCCESS,
  ACCOUNT_UNPIN_SUCCESS,
} from '../actions/accounts';

const initialState = ImmutableMap({
  accounts: ImmutableMap({
    items: ImmutableList(),
    loaded: false,
    isLoading: false,
  }),

  suggestions: ImmutableMap({
    value: '',
    items: ImmutableList(),
  }),
});

export default function listEditorReducer(state = initialState, action) {
  switch(action.type) {
  case PINNED_ACCOUNTS_EDITOR_RESET:
    return initialState;
  case PINNED_ACCOUNTS_FETCH_REQUEST:
    return state.setIn(['accounts', 'isLoading'], true);
  case PINNED_ACCOUNTS_FETCH_FAIL:
    return state.setIn(['accounts', 'isLoading'], false);
  case PINNED_ACCOUNTS_FETCH_SUCCESS:
    return state.update('accounts', accounts => accounts.withMutations(map => {
      map.set('isLoading', false);
      map.set('loaded', true);
      map.set('items', ImmutableList(action.accounts.map(item => item.id)));
    }));
  case PINNED_ACCOUNTS_SUGGESTIONS_FETCH_SUCCESS:
    return state.setIn(['suggestions', 'items'], ImmutableList(action.accounts.map(item => item.id)));
  case PINNED_ACCOUNTS_EDITOR_SUGGESTIONS_CHANGE:
    return state.setIn(['suggestions', 'value'], action.value);
  case PINNED_ACCOUNTS_EDITOR_SUGGESTIONS_CLEAR:
    return state.update('suggestions', suggestions => suggestions.withMutations(map => {
      map.set('items', ImmutableList());
      map.set('value', '');
    }));
  case ACCOUNT_PIN_SUCCESS:
    return state.updateIn(['accounts', 'items'], list => list.unshift(action.relationship.id));
  case ACCOUNT_UNPIN_SUCCESS:
    return state.updateIn(['accounts', 'items'], list => list.filterNot(item => item === action.relationship.id));
  default:
    return state;
  }
}
