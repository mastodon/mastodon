import { Map as ImmutableMap } from 'immutable';
import {
  LIST_CREATE_REQUEST,
  LIST_CREATE_FAIL,
  LIST_CREATE_SUCCESS,
  LIST_EDITOR_RESET,
  LIST_EDITOR_TITLE_CHANGE,
} from '../actions/lists';

const initialState = ImmutableMap({
  listId: null,
  isSubmitting: false,
  title: '',
});

export default function listEditorReducer(state = initialState, action) {
  switch(action.type) {
  case LIST_EDITOR_RESET:
    return initialState;
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
  default:
    return state;
  }
};
