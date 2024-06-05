import api from '../api';
import { me } from '../initial_state';

import { importFetchedStatuses } from './importer';

export const PINNED_STATUSES_FETCH_REQUEST = 'PINNED_STATUSES_FETCH_REQUEST';
export const PINNED_STATUSES_FETCH_SUCCESS = 'PINNED_STATUSES_FETCH_SUCCESS';
export const PINNED_STATUSES_FETCH_FAIL = 'PINNED_STATUSES_FETCH_FAIL';

export function fetchPinnedStatuses() {
  return (dispatch) => {
    dispatch(fetchPinnedStatusesRequest());

    api().get(`/api/v1/accounts/${me}/statuses`, { params: { pinned: true } }).then(response => {
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
