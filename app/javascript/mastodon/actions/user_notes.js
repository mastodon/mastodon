import api from '../api';

export const USER_NOTE_SUBMIT_REQUEST = 'USER_NOTE_SUBMIT_REQUEST';
export const USER_NOTE_SUBMIT_SUCCESS = 'USER_NOTE_SUBMIT_SUCCESS';
export const USER_NOTE_SUBMIT_FAIL    = 'USER_NOTE_SUBMIT_FAIL';

export const USER_NOTE_INIT_EDIT = 'USER_NOTE_INIT_EDIT';
export const USER_NOTE_CANCEL    = 'USER_NOTE_CANCEL';

export const USER_NOTE_CHANGE_COMMENT = 'USER_NOTE_CHANGE_COMMENT';

export function submitUserNote() {
  return (dispatch, getState) => {
    dispatch(submitUserNoteRequest());

    const id = getState().getIn(['user_notes', 'edit', 'account_id']);

    api(getState).post(`/api/v1/accounts/${id}/user_note`, {
      comment: getState().getIn(['user_notes', 'edit', 'comment']),
    }).then(response => {
      dispatch(submitUserNoteSuccess(response.data));
    }).catch(error => dispatch(submitUserNoteFail(error)));
  };
};

export function submitUserNoteRequest() {
  return {
    type: USER_NOTE_SUBMIT_REQUEST,
  };
};

export function submitUserNoteSuccess(relationship) {
  return {
    type: USER_NOTE_SUBMIT_SUCCESS,
    relationship,
  };
};

export function submitUserNoteFail(error) {
  return {
    type: USER_NOTE_SUBMIT_FAIL,
    error,
  };
};

export function initEditUserNote(account) {
  return (dispatch, getState) => {
    const comment = getState().getIn(['relationships', account.get('id'), 'comment']);

    dispatch({
      type: USER_NOTE_INIT_EDIT,
      account,
      comment,
    });
  };
};

export function cancelUserNote() {
  return {
    type: USER_NOTE_CANCEL,
  };
};

export function changeUserNoteComment(comment) {
  return {
    type: USER_NOTE_CHANGE_COMMENT,
    comment,
  };
};
