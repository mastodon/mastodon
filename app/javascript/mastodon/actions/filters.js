import api from '../api';

import { openModal } from './modal';

export const FILTERS_FETCH_REQUEST = 'FILTERS_FETCH_REQUEST';
export const FILTERS_FETCH_SUCCESS = 'FILTERS_FETCH_SUCCESS';
export const FILTERS_FETCH_FAIL    = 'FILTERS_FETCH_FAIL';


export const FILTERS_ACCOUNT_CREATE_REQUEST = 'FILTERS_ACCOUNT_CREATE_REQUEST';
export const FILTERS_ACCOUNT_CREATE_SUCCESS = 'FILTERS_ACCOUNT_CREATE_SUCCESS';
export const FILTERS_ACCOUNT_CREATE_FAIL    = 'FILTERS_ACCOUNT_CREATE_FAIL';

export const FILTERS_STATUS_CREATE_REQUEST = 'FILTERS_STATUS_CREATE_REQUEST';
export const FILTERS_STATUS_CREATE_SUCCESS = 'FILTERS_STATUS_CREATE_SUCCESS';
export const FILTERS_STATUS_CREATE_FAIL    = 'FILTERS_STATUS_CREATE_FAIL';

export const FILTERS_CREATE_REQUEST = 'FILTERS_CREATE_REQUEST';
export const FILTERS_CREATE_SUCCESS = 'FILTERS_CREATE_SUCCESS';
export const FILTERS_CREATE_FAIL    = 'FILTERS_CREATE_FAIL';

export const initAddFilter = (status, { contextType }) => dispatch =>
  dispatch(openModal({
    modalType: 'FILTER',
    modalProps: {
      statusId: status?.get('id'),
      contextType: contextType,
    },
  }));

export const fetchFilters = () => (dispatch, getState) => {
  dispatch({
    type: FILTERS_FETCH_REQUEST,
    skipLoading: true,
  });

  api(getState)
    .get('/api/v2/filters')
    .then(({ data }) => dispatch({
      type: FILTERS_FETCH_SUCCESS,
      filters: data,
      skipLoading: true,
    }))
    .catch(err => dispatch({
      type: FILTERS_FETCH_FAIL,
      err,
      skipLoading: true,
      skipAlert: true,
    }));
};

export const createFilterAccount = (params, onSuccess, onFail) => (dispatch, getState) => {
  dispatch(createFilterAccountRequest());

  api(getState).post(`/api/v2/filters/${params.filter_id}/accounts`, params).then(response => {
    dispatch(createFilterAccountSuccess(response.data));
    if (onSuccess) onSuccess();
  }).catch(error => {
    dispatch(createFilterAccountFail(error));
    if (onFail) onFail();
  });
};

export const createFilterAccountRequest = () => ({
  type: FILTERS_ACCOUNT_CREATE_REQUEST,
});

export const createFilterAccountSuccess = filter_account => ({
  type: FILTERS_ACCOUNT_CREATE_SUCCESS,
  filter_account,
});

export const createFilterAccountFail = error => ({
  type: FILTERS_ACCOUNT_CREATE_FAIL,
  error,
});

export const createFilterStatus = (params, onSuccess, onFail) => (dispatch, getState) => {
  dispatch(createFilterStatusRequest());

  api(getState).post(`/api/v2/filters/${params.filter_id}/statuses`, params).then(response => {
    dispatch(createFilterStatusSuccess(response.data));
    if (onSuccess) onSuccess();
  }).catch(error => {
    dispatch(createFilterStatusFail(error));
    if (onFail) onFail();
  });
};

export const createFilterStatusRequest = () => ({
  type: FILTERS_STATUS_CREATE_REQUEST,
});

export const createFilterStatusSuccess = filter_status => ({
  type: FILTERS_STATUS_CREATE_SUCCESS,
  filter_status,
});

export const createFilterStatusFail = error => ({
  type: FILTERS_STATUS_CREATE_FAIL,
  error,
});

export const createFilter = (params, onSuccess, onFail) => (dispatch, getState) => {
  dispatch(createFilterRequest());

  api(getState).post('/api/v2/filters', params).then(response => {
    dispatch(createFilterSuccess(response.data));
    if (onSuccess) onSuccess(response.data);
  }).catch(error => {
    dispatch(createFilterFail(error));
    if (onFail) onFail();
  });
};

export const createFilterRequest = () => ({
  type: FILTERS_CREATE_REQUEST,
});

export const createFilterSuccess = filter => ({
  type: FILTERS_CREATE_SUCCESS,
  filter,
});

export const createFilterFail = error => ({
  type: FILTERS_CREATE_FAIL,
  error,
});
