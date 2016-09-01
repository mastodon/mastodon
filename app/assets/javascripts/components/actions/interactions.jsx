import api from '../api'

export const REBLOG         = 'REBLOG';
export const REBLOG_REQUEST = 'REBLOG_REQUEST';
export const REBLOG_SUCCESS = 'REBLOG_SUCCESS';
export const REBLOG_FAIL    = 'REBLOG_FAIL';

export const FAVOURITE         = 'FAVOURITE';
export const FAVOURITE_REQUEST = 'FAVOURITE_REQUEST';
export const FAVOURITE_SUCCESS = 'FAVOURITE_SUCCESS';
export const FAVOURITE_FAIL    = 'FAVOURITE_FAIL';

export function reblog(status) {
  return function (dispatch, getState) {
    dispatch(reblogRequest(status));

    api(getState).post(`/api/statuses/${status.get('id')}/reblog`).then(function (response) {
      dispatch(reblogSuccess(status, response.data));
    }).catch(function (error) {
      dispatch(reblogFail(status, error));
    });
  };
}

export function reblogRequest(status) {
  return {
    type: REBLOG_REQUEST,
    status: status
  };
}

export function reblogSuccess(status, response) {
  return {
    type: REBLOG_SUCCESS,
    status: status,
    response: response
  };
}

export function reblogFail(status, error) {
  return {
    type: REBLOG_FAIL,
    status: status,
    error: error
  };
}

export function favourite(status) {
  return function (dispatch, getState) {
    dispatch(favouriteRequest(status));

    api(getState).post(`/api/statuses/${status.get('id')}/favourite`).then(function (response) {
      dispatch(favouriteSuccess(status, response.data));
    }).catch(function (error) {
      dispatch(favouriteFail(status, error));
    });
  };
}

export function favouriteRequest(status) {
  return {
    type: FAVOURITE_REQUEST,
    status: status
  };
}

export function favouriteSuccess(status, response) {
  return {
    type: FAVOURITE_SUCCESS,
    status: status,
    response: response
  };
}

export function favouriteFail(status, error) {
  return {
    type: FAVOURITE_FAIL,
    status: status,
    error: error
  };
}
