import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  GROUP_EDITOR_RESET,
  GROUP_EDITOR_TITLE_CHANGE,
  GROUP_CREATE_REQUEST,
  GROUP_CREATE_FAIL,
  GROUP_CREATE_SUCCESS,
} from '../actions/groups';

const initialState = ImmutableMap({
  groupId: null,
  isSubmitting: false,
  isChanged: false,
  displayName: '',
  note: '',
  avatar: null,
  header: null,
});

export default function groupEditorReducer(state = initialState, action) {
  switch(action.type) {
  case GROUP_EDITOR_RESET:
    return initialState;
  case GROUP_EDITOR_TITLE_CHANGE:
    return state.withMutations(map => {
      map.set('displayName', action.value);
      map.set('isChanged', true);
    });
  case GROUP_CREATE_REQUEST:
    return state.withMutations(map => {
      map.set('isSubmitting', true);
      map.set('isChanged', false);
    });
  case GROUP_CREATE_FAIL:
    return state.set('isSubmitting', false);
  case GROUP_CREATE_SUCCESS:
    return state.withMutations(map => {
      map.set('isSubmitting', false);
      map.set('groupId', action.group.id);
    });
  default:
    return state;
  }
};
