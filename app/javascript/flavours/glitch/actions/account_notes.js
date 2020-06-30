import api from 'flavours/glitch/util/api';

export const ACCOUNT_NOTE_SUBMIT_REQUEST = 'ACCOUNT_NOTE_SUBMIT_REQUEST';
export const ACCOUNT_NOTE_SUBMIT_SUCCESS = 'ACCOUNT_NOTE_SUBMIT_SUCCESS';
export const ACCOUNT_NOTE_SUBMIT_FAIL    = 'ACCOUNT_NOTE_SUBMIT_FAIL';

export const ACCOUNT_NOTE_INIT_EDIT = 'ACCOUNT_NOTE_INIT_EDIT';
export const ACCOUNT_NOTE_CANCEL    = 'ACCOUNT_NOTE_CANCEL';

export const ACCOUNT_NOTE_CHANGE_COMMENT = 'ACCOUNT_NOTE_CHANGE_COMMENT';

export function submitAccountNote() {
  return (dispatch, getState) => {
    dispatch(submitAccountNoteRequest());

    const id = getState().getIn(['account_notes', 'edit', 'account_id']);

    api(getState).post(`/api/v1/accounts/${id}/note`, {
      comment: getState().getIn(['account_notes', 'edit', 'comment']),
    }).then(response => {
      dispatch(submitAccountNoteSuccess(response.data));
    }).catch(error => dispatch(submitAccountNoteFail(error)));
  };
};

export function submitAccountNoteRequest() {
  return {
    type: ACCOUNT_NOTE_SUBMIT_REQUEST,
  };
};

export function submitAccountNoteSuccess(relationship) {
  return {
    type: ACCOUNT_NOTE_SUBMIT_SUCCESS,
    relationship,
  };
};

export function submitAccountNoteFail(error) {
  return {
    type: ACCOUNT_NOTE_SUBMIT_FAIL,
    error,
  };
};

export function initEditAccountNote(account) {
  return (dispatch, getState) => {
    const comment = getState().getIn(['relationships', account.get('id'), 'note']);

    dispatch({
      type: ACCOUNT_NOTE_INIT_EDIT,
      account,
      comment,
    });
  };
};

export function cancelAccountNote() {
  return {
    type: ACCOUNT_NOTE_CANCEL,
  };
};

export function changeAccountNoteComment(comment) {
  return {
    type: ACCOUNT_NOTE_CHANGE_COMMENT,
    comment,
  };
};
