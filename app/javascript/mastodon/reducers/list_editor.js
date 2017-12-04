import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  LIST_CREATE_REQUEST,
  LIST_CREATE_FAIL,
  LIST_CREATE_SUCCESS,
  LIST_EDITOR_RESET,
  LIST_EDITOR_SETUP,
  LIST_EDITOR_TITLE_CHANGE,
  LIST_ACCOUNTS_FETCH_REQUEST,
  LIST_ACCOUNTS_FETCH_SUCCESS,
  LIST_ACCOUNTS_FETCH_FAIL,
  LIST_EDITOR_SUGGESTIONS_READY,
  LIST_EDITOR_ADD_SUCCESS,
  LIST_EDITOR_REMOVE_SUCCESS,
} from '../actions/lists';

const initialState = ImmutableMap({
  listId: null,
  isSubmitting: false,
  title: '',

  accounts: ImmutableMap({
    next: null,
    items: ImmutableList(),
    loaded: false,
    isLoading: false,
  }),

  suggestions: ImmutableList(),
});

export default function listEditorReducer(state = initialState, action) {
  switch(action.type) {
  case LIST_EDITOR_RESET:
    return initialState;
  case LIST_EDITOR_SETUP:
    return state.withMutations(map => {
      map.set('listId', action.list.get('id'));
      map.set('title', action.list.get('title'));
      map.set('isSubmitting', false);
    });
  case LIST_EDITOR_TITLE_CHANGE:
    return state.set('title', action.value);
  case LIST_CREATE_REQUEST:
    return state.set('isSubmitting', true);
  case LIST_CREATE_FAIL:
    return state.set('isSubmitting', false);
  case LIST_CREATE_SUCCESS:
    return state.withMutations(map => {
      map.set('isSubmitting', false);
      map.set('listId', action.list.id);
    });
  case LIST_ACCOUNTS_FETCH_REQUEST:
    return state.setIn(['accounts', 'isLoading'], true);
  case LIST_ACCOUNTS_FETCH_FAIL:
    return state.setIn(['accounts', 'isLoading'], false);
  case LIST_ACCOUNTS_FETCH_SUCCESS:
    return state.update('accounts', accounts => accounts.withMutations(map => {
      map.set('isLoading', false);
      map.set('loaded', true);
      map.set('next', action.next);
      map.set('items', ImmutableList(action.accounts.map(item => item.id)));
    }));
  case LIST_EDITOR_SUGGESTIONS_READY:
    return state.set('suggestions', ImmutableList(action.accounts.map(item => item.id)));
  case LIST_EDITOR_ADD_SUCCESS:
    return state.updateIn(['accounts', 'items'], list => list.unshift(action.accountId));
  case LIST_EDITOR_REMOVE_SUCCESS:
    return state.updateIn(['accounts', 'items'], list => list.filterNot(item => item === action.accountId));
  default:
    return state;
  }
};
