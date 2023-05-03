import api from '../api';

export const ACCOUNT_NOTE_SUBMIT_REQUEST = 'ACCOUNT_NOTE_SUBMIT_REQUEST';
export const ACCOUNT_NOTE_SUBMIT_SUCCESS = 'ACCOUNT_NOTE_SUBMIT_SUCCESS';
export const ACCOUNT_NOTE_SUBMIT_FAIL    = 'ACCOUNT_NOTE_SUBMIT_FAIL';

export function submitAccountNote(id, value) {
  return (dispatch, getState) => {
    dispatch(submitAccountNoteRequest());

    api(getState).post(`/api/v1/accounts/${id}/note`, {
      comment: value,
    }).then(response => {
      dispatch(submitAccountNoteSuccess(response.data));
    }).catch(error => dispatch(submitAccountNoteFail(error)));
  };
}

export function submitAccountNoteRequest() {
  return {
    type: ACCOUNT_NOTE_SUBMIT_REQUEST,
  };
}

export function submitAccountNoteSuccess(relationship) {
  return {
    type: ACCOUNT_NOTE_SUBMIT_SUCCESS,
    relationship,
  };
}

export function submitAccountNoteFail(error) {
  return {
    type: ACCOUNT_NOTE_SUBMIT_FAIL,
    error,
  };
}
