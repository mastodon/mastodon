import api   from '../api';
import axios from 'axios';

export const STATUS_FETCH_REQUEST = 'STATUS_FETCH_REQUEST';
export const STATUS_FETCH_SUCCESS = 'STATUS_FETCH_SUCCESS';
export const STATUS_FETCH_FAIL    = 'STATUS_FETCH_FAIL';

export const STATUS_DELETE_REQUEST = 'STATUS_DELETE_REQUEST';
export const STATUS_DELETE_SUCCESS = 'STATUS_DELETE_SUCCESS';
export const STATUS_DELETE_FAIL    = 'STATUS_DELETE_FAIL';

export function fetchStatusRequest(id) {
  return {
    type: STATUS_FETCH_REQUEST,
    id: id
  };
};

export function fetchStatus(id) {
  return (dispatch, getState) => {
    const boundApi = api(getState);

    dispatch(fetchStatusRequest(id));

    axios.all([boundApi.get(`/api/v1/statuses/${id}`), boundApi.get(`/api/v1/statuses/${id}/context`)]).then(values => {
      dispatch(fetchStatusSuccess(values[0].data, values[1].data));
    }).catch(error => {
      console.error(error);
      dispatch(fetchStatusFail(id, error));
    });
  };
};

export function fetchStatusSuccess(status, context) {
  return {
    type: STATUS_FETCH_SUCCESS,
    status: status,
    context: context
  };
};

export function fetchStatusFail(id, error) {
  return {
    type: STATUS_FETCH_FAIL,
    id: id,
    error: error
  };
};

export function deleteStatus(id) {
  return (dispatch, getState) => {
    dispatch(deleteStatusRequest(id));

    api(getState).delete(`/api/v1/statuses/${id}`).then(response => {
      dispatch(deleteStatusSuccess(id));
    }).catch(error => {
      console.error(error);
      dispatch(deleteStatusFail(id, error));
    });
  };
};

export function deleteStatusRequest(id) {
  return {
    type: STATUS_DELETE_REQUEST,
    id: id
  };
};

export function deleteStatusSuccess(id) {
  return {
    type: STATUS_DELETE_SUCCESS,
    id: id
  };
};

export function deleteStatusFail(id, error) {
  return {
    type: STATUS_DELETE_FAIL,
    id: id,
    error: error
  };
};
