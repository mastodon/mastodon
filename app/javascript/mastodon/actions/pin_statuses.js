import api from '../api';
import { importFetchedStatuses } from './importer';

export const PINNED_STATUSES_FETCH_REQUEST = 'PINNED_STATUSES_FETCH_REQUEST';
export const PINNED_STATUSES_FETCH_SUCCESS = 'PINNED_STATUSES_FETCH_SUCCESS';
export const PINNED_STATUSES_FETCH_FAIL = 'PINNED_STATUSES_FETCH_FAIL';

import { me } from '../initial_state';

export function fetchPinnedStatuses() {
  return (dispatch, getState) => {
    dispatch(fetchPinnedStatusesRequest());

    api(getState).get(`/api/v1/accounts/${me}/statuses`, { params: { pinned: true } }).then(response => {
      dispatch(importFetchedStatuses(response.data));
      dispatch(fetchPinnedStatusesSuccess(response.data, null));
    }).catch(error => {
      dispatch(fetchPinnedStatusesFail(error));
    });
  };
}

export function fetchPinnedStatusesRequest() {
  return {
    type: PINNED_STATUSES_FETCH_REQUEST,
  };
}

export function fetchPinnedStatusesSuccess(statuses, next) {
  return {
    type: PINNED_STATUSES_FETCH_SUCCESS,
    statuses,
    next,
  };
}

export function fetchPinnedStatusesFail(error) {
  return {
    type: PINNED_STATUSES_FETCH_FAIL,
    error,
  };
}
