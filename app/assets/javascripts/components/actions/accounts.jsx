import api       from '../api'
import axios     from 'axios';
import Immutable from 'immutable';

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

export const ACCOUNT_BLOCK_REQUEST = 'ACCOUNT_BLOCK_REQUEST';
export const ACCOUNT_BLOCK_SUCCESS = 'ACCOUNT_BLOCK_SUCCESS';
export const ACCOUNT_BLOCK_FAIL    = 'ACCOUNT_BLOCK_FAIL';

export const ACCOUNT_UNBLOCK_REQUEST = 'ACCOUNT_UNBLOCK_REQUEST';
export const ACCOUNT_UNBLOCK_SUCCESS = 'ACCOUNT_UNBLOCK_SUCCESS';
export const ACCOUNT_UNBLOCK_FAIL    = 'ACCOUNT_UNBLOCK_FAIL';

export const ACCOUNT_TIMELINE_FETCH_REQUEST = 'ACCOUNT_TIMELINE_FETCH_REQUEST';
export const ACCOUNT_TIMELINE_FETCH_SUCCESS = 'ACCOUNT_TIMELINE_FETCH_SUCCESS';
export const ACCOUNT_TIMELINE_FETCH_FAIL    = 'ACCOUNT_TIMELINE_FETCH_FAIL';

export const ACCOUNT_TIMELINE_EXPAND_REQUEST = 'ACCOUNT_TIMELINE_EXPAND_REQUEST';
export const ACCOUNT_TIMELINE_EXPAND_SUCCESS = 'ACCOUNT_TIMELINE_EXPAND_SUCCESS';
export const ACCOUNT_TIMELINE_EXPAND_FAIL    = 'ACCOUNT_TIMELINE_EXPAND_FAIL';

export function setAccountSelf(account) {
  return {
    type: ACCOUNT_SET_SELF,
    account: account
  };
};

export function fetchAccount(id) {
  return (dispatch, getState) => {
    const boundApi = api(getState);

    dispatch(fetchAccountRequest(id));

    axios.all([boundApi.get(`/api/v1/accounts/${id}`), boundApi.get(`/api/v1/accounts/relationships?id=${id}`)]).then(values => {
      dispatch(fetchAccountSuccess(values[0].data, values[1].data[0]));
    }).catch(error => {
      console.error(error);
      dispatch(fetchAccountFail(id, error));
    });
  };
};

export function fetchAccountTimeline(id) {
  return (dispatch, getState) => {
    dispatch(fetchAccountTimelineRequest(id));

    api(getState).get(`/api/v1/accounts/${id}/statuses`).then(response => {
      dispatch(fetchAccountTimelineSuccess(id, response.data));
    }).catch(error => {
      console.error(error);
      dispatch(fetchAccountTimelineFail(id, error));
    });
  };
};

export function expandAccountTimeline(id) {
  return (dispatch, getState) => {
    const lastId = getState().getIn(['timelines', 'accounts_timelines', id], Immutable.List()).last();

    dispatch(expandAccountTimelineRequest(id));

    api(getState).get(`/api/v1/accounts/${id}/statuses?max_id=${lastId}`).then(response => {
      dispatch(expandAccountTimelineSuccess(id, response.data));
    }).catch(error => {
      console.error(error);
      dispatch(expandAccountTimelineFail(id, error));
    });
  };
};

export function fetchAccountRequest(id) {
  return {
    type: ACCOUNT_FETCH_REQUEST,
    id: id
  };
};

export function fetchAccountSuccess(account, relationship) {
  return {
    type: ACCOUNT_FETCH_SUCCESS,
    account: account,
    relationship: relationship
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

    api(getState).post(`/api/v1/accounts/${id}/follow`).then(response => {
      dispatch(followAccountSuccess(response.data));
    }).catch(error => {
      console.error(error);
      dispatch(followAccountFail(error));
    });
  };
};

export function unfollowAccount(id) {
  return (dispatch, getState) => {
    dispatch(unfollowAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/unfollow`).then(response => {
      dispatch(unfollowAccountSuccess(response.data));
    }).catch(error => {
      console.error(error);
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

export function followAccountSuccess(relationship) {
  return {
    type: ACCOUNT_FOLLOW_SUCCESS,
    relationship: relationship
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

export function unfollowAccountSuccess(relationship) {
  return {
    type: ACCOUNT_UNFOLLOW_SUCCESS,
    relationship: relationship
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

export function expandAccountTimelineRequest(id) {
  return {
    type: ACCOUNT_TIMELINE_EXPAND_REQUEST,
    id: id
  };
};

export function expandAccountTimelineSuccess(id, statuses) {
  return {
    type: ACCOUNT_TIMELINE_EXPAND_SUCCESS,
    id: id,
    statuses: statuses
  };
};

export function expandAccountTimelineFail(id, error) {
  return {
    type: ACCOUNT_TIMELINE_EXPAND_FAIL,
    id: id,
    error: error
  };
};

export function blockAccount(id) {
  return (dispatch, getState) => {
    dispatch(blockAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/block`).then(response => {
      dispatch(blockAccountSuccess(response.data));
    }).catch(error => {
      console.error(error);
      dispatch(blockAccountFail(id, error));
    });
  };
};

export function unblockAccount(id) {
  return (dispatch, getState) => {
    dispatch(unblockAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/unblock`).then(response => {
      dispatch(unblockAccountSuccess(response.data));
    }).catch(error => {
      console.error(error);
      dispatch(unblockAccountFail(id, error));
    });
  };
};

export function blockAccountRequest(id) {
  return {
    type: ACCOUNT_BLOCK_REQUEST,
    id: id
  };
};

export function blockAccountSuccess(relationship) {
  return {
    type: ACCOUNT_BLOCK_SUCCESS,
    relationship: relationship
  };
};

export function blockAccountFail(error) {
  return {
    type: ACCOUNT_BLOCK_FAIL,
    error: error
  };
};

export function unblockAccountRequest(id) {
  return {
    type: ACCOUNT_UNBLOCK_REQUEST,
    id: id
  };
};

export function unblockAccountSuccess(relationship) {
  return {
    type: ACCOUNT_UNBLOCK_SUCCESS,
    relationship: relationship
  };
};

export function unblockAccountFail(error) {
  return {
    type: ACCOUNT_UNBLOCK_FAIL,
    error: error
  };
};
