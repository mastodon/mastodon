import api from '../api'

export const ACCOUNT_SET_SELF      = 'ACCOUNT_SET_SELF';
export const ACCOUNT_FETCH         = 'ACCOUNT_FETCH';
export const ACCOUNT_FETCH_REQUEST = 'ACCOUNT_FETCH_REQUEST';
export const ACCOUNT_FETCH_SUCCESS = 'ACCOUNT_FETCH_SUCCESS';
export const ACCOUNT_FETCH_FAIL    = 'ACCOUNT_FETCH_FAIL';

export function setAccountSelf(account) {
  return {
    type: ACCOUNT_SET_SELF,
    account: account
  };
};

export function fetchAccount(id) {
  return (dispatch, getState) => {
    dispatch(fetchAccountRequest(id));

    api(getState).get(`/api/accounts/${id}`).then(response => {
      dispatch(fetchAccountSuccess(response.data));
    }).catch(error => {
      dispatch(fetchAccountFail(id, error));
    });
  };
};

export function fetchAccountRequest(id) {
  return {
    type: ACCOUNT_FETCH_REQUEST,
    id: id
  };
};

export function fetchAccountSuccess(account) {
  return {
    type: ACCOUNT_FETCH_SUCCESS,
    account: account
  };
};

export function fetchAccountFail(id, error) {
  return {
    type: ACCOUNT_FETCH_FAIL,
    id: id,
    error: error
  };
};
