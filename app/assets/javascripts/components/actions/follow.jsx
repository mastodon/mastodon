import api from '../api'

export const FOLLOW_CHANGE         = 'FOLLOW_CHANGE';
export const FOLLOW_SUBMIT         = 'FOLLOW_SUBMIT';
export const FOLLOW_SUBMIT_REQUEST = 'FOLLOW_SUBMIT_REQUEST';
export const FOLLOW_SUBMIT_SUCCESS = 'FOLLOW_SUBMIT_SUCCESS';
export const FOLLOW_SUBMIT_FAIL    = 'FOLLOW_SUBMIT_FAIL';

export function followChange(text) {
  return {
    type: FOLLOW_CHANGE,
    text: text
  };
}

export function followSubmit() {
  return function (dispatch, getState) {
    dispatch(followSubmitRequest());

    api(getState).post('/api/follows', {
      uri: getState().getIn(['follow', 'text'])
    }).then(function (response) {
      dispatch(followSubmitSuccess(response.data));
    }).catch(function (error) {
      dispatch(followSubmitFail(error));
    });
  };
}

export function followSubmitRequest() {
  return {
    type: FOLLOW_SUBMIT_REQUEST
  };
}

export function followSubmitSuccess(account) {
  return {
    type: FOLLOW_SUBMIT_SUCCESS,
    account: account
  };
}

export function followSubmitFail(error) {
  return {
    type: FOLLOW_SUBMIT_FAIL,
    error: error
  };
}
