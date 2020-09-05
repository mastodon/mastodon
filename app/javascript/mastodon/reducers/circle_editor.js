import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  CIRCLE_CREATE_REQUEST,
  CIRCLE_CREATE_FAIL,
  CIRCLE_CREATE_SUCCESS,
  CIRCLE_UPDATE_REQUEST,
  CIRCLE_UPDATE_FAIL,
  CIRCLE_UPDATE_SUCCESS,
  CIRCLE_EDITOR_RESET,
  CIRCLE_EDITOR_SETUP,
  CIRCLE_EDITOR_TITLE_CHANGE,
  CIRCLE_ACCOUNTS_FETCH_REQUEST,
  CIRCLE_ACCOUNTS_FETCH_SUCCESS,
  CIRCLE_ACCOUNTS_FETCH_FAIL,
  CIRCLE_EDITOR_SUGGESTIONS_READY,
  CIRCLE_EDITOR_SUGGESTIONS_CLEAR,
  CIRCLE_EDITOR_SUGGESTIONS_CHANGE,
  CIRCLE_EDITOR_ADD_SUCCESS,
  CIRCLE_EDITOR_REMOVE_SUCCESS,
} from '../actions/circles';

const initialState = ImmutableMap({
  circleId: null,
  isSubmitting: false,
  isChanged: false,
  title: '',

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

export default function circleEditorReducer(state = initialState, action) {
  switch(action.type) {
  case CIRCLE_EDITOR_RESET:
    return initialState;
  case CIRCLE_EDITOR_SETUP:
    return state.withMutations(map => {
      map.set('circleId', action.circle.get('id'));
      map.set('title', action.circle.get('title'));
      map.set('isSubmitting', false);
    });
  case CIRCLE_EDITOR_TITLE_CHANGE:
    return state.withMutations(map => {
      map.set('title', action.value);
      map.set('isChanged', true);
    });
  case CIRCLE_CREATE_REQUEST:
  case CIRCLE_UPDATE_REQUEST:
    return state.withMutations(map => {
      map.set('isSubmitting', true);
      map.set('isChanged', false);
    });
  case CIRCLE_CREATE_FAIL:
  case CIRCLE_UPDATE_FAIL:
    return state.set('isSubmitting', false);
  case CIRCLE_CREATE_SUCCESS:
  case CIRCLE_UPDATE_SUCCESS:
    return state.withMutations(map => {
      map.set('isSubmitting', false);
      map.set('circleId', action.circle.id);
    });
  case CIRCLE_ACCOUNTS_FETCH_REQUEST:
    return state.setIn(['accounts', 'isLoading'], true);
  case CIRCLE_ACCOUNTS_FETCH_FAIL:
    return state.setIn(['accounts', 'isLoading'], false);
  case CIRCLE_ACCOUNTS_FETCH_SUCCESS:
    return state.update('accounts', accounts => accounts.withMutations(map => {
      map.set('isLoading', false);
      map.set('loaded', true);
      map.set('items', ImmutableList(action.accounts.map(item => item.id)));
    }));
  case CIRCLE_EDITOR_SUGGESTIONS_CHANGE:
    return state.setIn(['suggestions', 'value'], action.value);
  case CIRCLE_EDITOR_SUGGESTIONS_READY:
    return state.setIn(['suggestions', 'items'], ImmutableList(action.accounts.map(item => item.id)));
  case CIRCLE_EDITOR_SUGGESTIONS_CLEAR:
    return state.update('suggestions', suggestions => suggestions.withMutations(map => {
      map.set('items', ImmutableList());
      map.set('value', '');
    }));
  case CIRCLE_EDITOR_ADD_SUCCESS:
    return state.updateIn(['accounts', 'items'], circle => circle.unshift(action.accountId));
  case CIRCLE_EDITOR_REMOVE_SUCCESS:
    return state.updateIn(['accounts', 'items'], circle => circle.filterNot(item => item === action.accountId));
  default:
    return state;
  }
};
