import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  LIST_ADDER_RESET,
  LIST_ADDER_SETUP,
  LIST_ADDER_LISTS_FETCH_REQUEST,
  LIST_ADDER_LISTS_FETCH_SUCCESS,
  LIST_ADDER_LISTS_FETCH_FAIL,
  LIST_EDITOR_ADD_SUCCESS,
  LIST_EDITOR_REMOVE_SUCCESS,
} from '../actions/lists';

const initialState = ImmutableMap({
  accountId: null,

  lists: ImmutableMap({
    items: ImmutableList(),
    loaded: false,
    isLoading: false,
  }),
});

export default function listAdderReducer(state = initialState, action) {
  switch(action.type) {
  case LIST_ADDER_RESET:
    return initialState;
  case LIST_ADDER_SETUP:
    return state.withMutations(map => {
      map.set('accountId', action.account.get('id'));
    });
  case LIST_ADDER_LISTS_FETCH_REQUEST:
    return state.setIn(['lists', 'isLoading'], true);
  case LIST_ADDER_LISTS_FETCH_FAIL:
    return state.setIn(['lists', 'isLoading'], false);
  case LIST_ADDER_LISTS_FETCH_SUCCESS:
    return state.update('lists', lists => lists.withMutations(map => {
      map.set('isLoading', false);
      map.set('loaded', true);
      map.set('items', ImmutableList(action.lists.map(item => item.id)));
    }));
  case LIST_EDITOR_ADD_SUCCESS:
    return state.updateIn(['lists', 'items'], list => list.unshift(action.listId));
  case LIST_EDITOR_REMOVE_SUCCESS:
    return state.updateIn(['lists', 'items'], list => list.filterNot(item => item === action.listId));
  default:
    return state;
  }
};
