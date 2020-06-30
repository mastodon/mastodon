import { Map as ImmutableMap } from 'immutable';

import {
  ACCOUNT_NOTE_INIT_EDIT,
  ACCOUNT_NOTE_CANCEL,
  ACCOUNT_NOTE_CHANGE_COMMENT,
  ACCOUNT_NOTE_SUBMIT_REQUEST,
  ACCOUNT_NOTE_SUBMIT_FAIL,
  ACCOUNT_NOTE_SUBMIT_SUCCESS,
} from '../actions/account_notes';

const initialState = ImmutableMap({
  edit: ImmutableMap({
    isSubmitting: false,
    account_id: null,
    comment: null,
  }),
});

export default function account_notes(state = initialState, action) {
  switch (action.type) {
  case ACCOUNT_NOTE_INIT_EDIT:
    return state.withMutations((state) => {
      state.setIn(['edit', 'isSubmitting'], false);
      state.setIn(['edit', 'account_id'], action.account.get('id'));
      state.setIn(['edit', 'comment'], action.comment);
    });
  case ACCOUNT_NOTE_CHANGE_COMMENT:
    return state.setIn(['edit', 'comment'], action.comment);
  case ACCOUNT_NOTE_SUBMIT_REQUEST:
    return state.setIn(['edit', 'isSubmitting'], true);
  case ACCOUNT_NOTE_SUBMIT_FAIL:
    return state.setIn(['edit', 'isSubmitting'], false);
  case ACCOUNT_NOTE_SUBMIT_SUCCESS:
  case ACCOUNT_NOTE_CANCEL:
    return state.withMutations((state) => {
      state.setIn(['edit', 'isSubmitting'], false);
      state.setIn(['edit', 'account_id'], null);
      state.setIn(['edit', 'comment'], null);
    });
  default:
    return state;
  }
}
