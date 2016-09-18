import api from '../api'

export const ACCOUNT_SET_SELF = 'ACCOUNT_SET_SELF';

export const ACCOUNT_FETCH_REQUEST = 'ACCOUNT_FETCH_REQUEST';
export const ACCOUNT_FETCH_SUCCESS = 'ACCOUNT_FETCH_SUCCESS';
export const ACCOUNT_FETCH_FAIL    = 'ACCOUNT_FETCH_FAIL';

export const ACCOUNT_FOLLOW_REQUEST = 'ACCOUNT_FOLLOW_REQUEST';
export const ACCOUNT_FOLLOW_SUCCESS = 'ACCOUNT_FOLLOW_SUCCESS';
export const ACCOUNT_FOLLOW_FAIL    = 'ACCOUNT_FOLLOW_FAIL';

export const ACCOUNT_UNFOLLOW_REQUEST = 'ACCOUNT_UNFOLLOW_REQUEST';
export const ACCOUNT_UNFOLLOW_SUCCESS = 'ACCOUNT_UNFOLLOW_SUCCESS';
export const ACCOUNT_UNFOLLOW_FAIL    = 'ACCOUNT_UNFOLLOW_FAIL';

export const ACCOUNT_TIMELINE_FETCH_REQUEST = 'ACCOUNT_TIMELINE_FETCH_REQUEST';
export const ACCOUNT_TIMELINE_FETCH_SUCCESS = 'ACCOUNT_TIMELINE_FETCH_SUCCESS';
export const ACCOUNT_TIMELINE_FETCH_FAIL    = 'ACCOUNT_TIMELINE_FETCH_FAIL';

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

export function fetchAccountTimeline(id) {
  return (dispatch, getState) => {
    dispatch(fetchAccountTimelineRequest(id));

    api(getState).get(`/api/accounts/${id}/statuses`).then(response => {
      dispatch(fetchAccountTimelineSuccess(id, response.data));
    }).catch(error => {
      dispatch(fetchAccountTimelineFail(id, error));
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

export function followAccount(id) {
  return (dispatch, getState) => {
    dispatch(followAccountRequest(id));

    api(getState).post(`/api/accounts/${id}/follow`).then(response => {
      dispatch(followAccountSuccess(response.data));
    }).catch(error => {
      dispatch(followAccountFail(error));
    });
  };
};

export function unfollowAccount(id) {
  return (dispatch, getState) => {
    dispatch(unfollowAccountRequest(id));

    api(getState).post(`/api/accounts/${id}/unfollow`).then(response => {
      dispatch(unfollowAccountSuccess(response.data));
    }).catch(error => {
      dispatch(unfollowAccountFail(error));
    });
  }
};

export function followAccountRequest(id) {
  return {
    type: ACCOUNT_FOLLOW_REQUEST,
    id: id
  };
};

export function followAccountSuccess(account) {
  return {
    type: ACCOUNT_FOLLOW_SUCCESS,
    account: account
  };
};

export function followAccountFail(error) {
  return {
    type: ACCOUNT_FOLLOW_FAIL,
    error: error
  };
};

export function unfollowAccountRequest(id) {
  return {
    type: ACCOUNT_UNFOLLOW_REQUEST,
    id: id
  };
};

export function unfollowAccountSuccess(account) {
  return {
    type: ACCOUNT_UNFOLLOW_SUCCESS,
    account: account
  };
};

export function unfollowAccountFail(error) {
  return {
    type: ACCOUNT_UNFOLLOW_FAIL,
    error: error
  };
};

export function fetchAccountTimelineRequest(id) {
  return {
    type: ACCOUNT_TIMELINE_FETCH_REQUEST,
    id: id
  };
};

export function fetchAccountTimelineSuccess(id, statuses) {
  return {
    type: ACCOUNT_TIMELINE_FETCH_SUCCESS,
    id: id,
    statuses: statuses
  };
};

export function fetchAccountTimelineFail(id, error) {
  return {
    type: ACCOUNT_TIMELINE_FETCH_FAIL,
    id: id,
    error: error
  };
};
