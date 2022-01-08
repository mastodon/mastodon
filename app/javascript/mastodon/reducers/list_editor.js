import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  LIST_CREATE_REQUEST,
  LIST_CREATE_FAIL,
  LIST_CREATE_SUCCESS,
  LIST_UPDATE_REQUEST,
  LIST_UPDATE_FAIL,
  LIST_UPDATE_SUCCESS,
  LIST_EDITOR_RESET,
  LIST_EDITOR_SETUP,
  LIST_EDITOR_TITLE_CHANGE,
  LIST_EDITOR_HASHTAG_CHANGE,
  LIST_EDITOR_ADD_SUCCESS,
  LIST_EDITOR_REMOVE_SUCCESS,
  UPDATE_HASHTAGS_USERS,
} from '../actions/lists';

const initialState = ImmutableMap({
  listId: null,
  isSubmitting: false,
  isChanged: false,
  title: '',
  hashtags: '',
  hashtagsUsers: '',
});

export default function listEditorReducer(state = initialState, action) {
  switch (action.type) {
    case LIST_EDITOR_RESET:
      return initialState;
    case LIST_EDITOR_SETUP:
      return state.withMutations((map) => {
        map.set('listId', action.list.get('id'));
        map.set('title', action.list.get('title'));
        map.set('hashtagsUsers', action.list.get('hashtags_users'));
        map.set('isSubmitting', false);
      });
    case LIST_EDITOR_TITLE_CHANGE:
      return state.withMutations((map) => {
        map.set('title', action.value);
        map.set('isChanged', true);
      });
    case LIST_EDITOR_HASHTAG_CHANGE:
      return state.withMutations((map) => {
        map.set('hashtags', action.hashtags);
        map.set('isChanged', true);
      });
    case LIST_CREATE_REQUEST:
    case LIST_UPDATE_REQUEST:
      return state.withMutations((map) => {
        map.set('isSubmitting', true);
      });
    case LIST_CREATE_FAIL:
    case LIST_UPDATE_FAIL:
      return state.set('isSubmitting', false);
    case LIST_CREATE_SUCCESS:
    case LIST_UPDATE_SUCCESS:
      return state.withMutations((map) => {
        map.set('isSubmitting', false);
        map.set('listId', action.list.id);
      });
    case LIST_EDITOR_ADD_SUCCESS:
      return state.updateIn(['accounts', 'items'], (list) =>
        list.unshift(action.accountId)
      );
    case LIST_EDITOR_REMOVE_SUCCESS:
      return state.updateIn(['accounts', 'items'], (list) =>
        list.filterNot((item) => item === action.accountId)
      );
    case UPDATE_HASHTAGS_USERS:
      return state.withMutations((map) => {
        map.set('hashtagsUsers', action.hashtagsUsersJSON);
      });
    default:
      return state;
  }
}
