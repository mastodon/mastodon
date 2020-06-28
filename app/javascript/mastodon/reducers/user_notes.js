import { Map as ImmutableMap } from 'immutable';

import {
  USER_NOTE_INIT_EDIT,
  USER_NOTE_CANCEL,
  USER_NOTE_CHANGE_COMMENT,
  USER_NOTE_SUBMIT_REQUEST,
  USER_NOTE_SUBMIT_FAIL,
  USER_NOTE_SUBMIT_SUCCESS,
} from '../actions/user_notes';

const initialState = ImmutableMap({
  edit: ImmutableMap({
    isSubmitting: false,
    account_id: null,
    comment: null,
  }),
});

export default function user_notes(state = initialState, action) {
  switch (action.type) {
  case USER_NOTE_INIT_EDIT:
    return state.withMutations((state) => {
      state.setIn(['edit', 'isSubmitting'], false);
      state.setIn(['edit', 'account_id'], action.account.get('id'));
      state.setIn(['edit', 'comment'], action.comment);
    });
  case USER_NOTE_CHANGE_COMMENT:
    return state.setIn(['edit', 'comment'], action.comment);
  case USER_NOTE_SUBMIT_REQUEST:
    return state.setIn(['edit', 'isSubmitting'], true);
  case USER_NOTE_SUBMIT_FAIL:
    return state.setIn(['edit', 'isSubmitting'], false);
  case USER_NOTE_SUBMIT_SUCCESS:
  case USER_NOTE_CANCEL:
    return state.withMutations((state) => {
      state.setIn(['edit', 'isSubmitting'], false);
      state.setIn(['edit', 'account_id'], null);
      state.setIn(['edit', 'comment'], null);
    });
  default:
    return state;
  }
}
