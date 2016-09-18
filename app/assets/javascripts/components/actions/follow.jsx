import api from '../api'

export const FOLLOW_CHANGE         = 'FOLLOW_CHANGE';
export const FOLLOW_SUBMIT_REQUEST = 'FOLLOW_SUBMIT_REQUEST';
export const FOLLOW_SUBMIT_SUCCESS = 'FOLLOW_SUBMIT_SUCCESS';
export const FOLLOW_SUBMIT_FAIL    = 'FOLLOW_SUBMIT_FAIL';

export function changeFollow(text) {
  return {
    type: FOLLOW_CHANGE,
    text: text
  };
};

export function submitFollow() {
  return function (dispatch, getState) {
    dispatch(submitFollowRequest());

    api(getState).post('/api/follows', {
      uri: getState().getIn(['follow', 'text'])
    }).then(function (response) {
      dispatch(submitFollowSuccess(response.data));
    }).catch(function (error) {
      dispatch(submitFollowFail(error));
    });
  };
};

export function submitFollowRequest() {
  return {
    type: FOLLOW_SUBMIT_REQUEST
  };
};

export function submitFollowSuccess(account) {
  return {
    type: FOLLOW_SUBMIT_SUCCESS,
    account: account
  };
};

export function submitFollowFail(error) {
  return {
    type: FOLLOW_SUBMIT_FAIL,
    error: error
  };
};
