import api from '../api';

export const PINNED_STATUSES_FETCH_REQUEST = 'PINNED_STATUSES_FETCH_REQUEST';
export const PINNED_STATUSES_FETCH_SUCCESS = 'PINNED_STATUSES_FETCH_SUCCESS';
export const PINNED_STATUSES_FETCH_FAIL = 'PINNED_STATUSES_FETCH_FAIL';

export function fetchPinnedStatuses() {
  return (dispatch, getState) => {
    dispatch(fetchPinnedStatusesRequest());

    const accountId = getState().getIn(['meta', 'me']);
    api(getState).get(`/api/v1/accounts/${accountId}/statuses`, { params: { pinned: true } }).then(response => {
      dispatch(fetchPinnedStatusesSuccess(response.data, null));
    }).catch(error => {
      dispatch(fetchPinnedStatusesFail(error));
    });
  };
};

export function fetchPinnedStatusesRequest() {
  return {
    type: PINNED_STATUSES_FETCH_REQUEST,
  };
};

export function fetchPinnedStatusesSuccess(statuses, next) {
  return {
    type: PINNED_STATUSES_FETCH_SUCCESS,
    statuses,
    next,
  };
};

export function fetchPinnedStatusesFail(error) {
  return {
    type: PINNED_STATUSES_FETCH_FAIL,
    error,
  };
};
