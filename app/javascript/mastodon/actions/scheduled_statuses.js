import api, { getLinks } from '../api';

export const SCHEDULED_STATUSES_FETCH_REQUEST = 'SCHEDULED_STATUSES_FETCH_REQUEST';
export const SCHEDULED_STATUSES_FETCH_SUCCESS = 'SCHEDULED_STATUSES_FETCH_SUCCESS';
export const SCHEDULED_STATUSES_FETCH_FAIL = 'SCHEDULED_STATUSES_FETCH_FAIL';

export const SCHEDULED_STATUSES_EXPAND_REQUEST = 'SCHEDULED_STATUSES_EXPAND_REQUEST';
export const SCHEDULED_STATUSES_EXPAND_SUCCESS = 'SCHEDULED_STATUSES_EXPAND_SUCCESS';
export const SCHEDULED_STATUSES_EXPAND_FAIL = 'SCHEDULED_STATUSES_EXPAND_FAIL';

export const SCHEDULED_STATUS_CREATE_SUCCESS = 'SCHEDULED_STATUS_CREATE_SUCCESS';
export const SCHEDULED_STATUS_UPDATE_SUCCESS = 'SCHEDULED_STATUS_UPDATE_SUCCESS';
export const SCHEDULED_STATUS_CANCEL_SUCCESS = 'SCHEDULED_STATUS_CANCEL_SUCCESS';

export function fetchScheduledStatuses() {
  return (dispatch, getState) => {
    if (getState().getIn(['scheduled_statuses', 'isLoading'])) {
      return;
    }

    dispatch({ type: SCHEDULED_STATUSES_FETCH_REQUEST });

    api().get('/api/v1/scheduled_statuses').then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch({
        type: SCHEDULED_STATUSES_FETCH_SUCCESS,
        statuses: response.data,
        next: next ? next.uri : null,
      });
    }).catch(error => {
      dispatch({ type: SCHEDULED_STATUSES_FETCH_FAIL, error });
    });
  };
}

export function expandScheduledStatuses() {
  return (dispatch, getState) => {
    const url = getState().getIn(['scheduled_statuses', 'next'], null);

    if (url === null || getState().getIn(['scheduled_statuses', 'isLoading'])) {
      return;
    }

    dispatch({ type: SCHEDULED_STATUSES_EXPAND_REQUEST });

    api().get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch({
        type: SCHEDULED_STATUSES_EXPAND_SUCCESS,
        statuses: response.data,
        next: next ? next.uri : null,
      });
    }).catch(error => {
      dispatch({ type: SCHEDULED_STATUSES_EXPAND_FAIL, error });
    });
  };
}

export const createScheduledStatusSuccess = status => ({
  type: SCHEDULED_STATUS_CREATE_SUCCESS,
  status,
});

export function updateScheduledStatus(id, scheduledAt) {
  return dispatch => {
    dispatch({ type: SCHEDULED_STATUSES_FETCH_REQUEST });

    api().put(`/api/v1/scheduled_statuses/${id}`, {
      scheduled_at: scheduledAt,
    }).then(response => {
      dispatch({
        type: SCHEDULED_STATUS_UPDATE_SUCCESS,
        status: response.data,
      });
    }).catch(error => {
      dispatch({ type: SCHEDULED_STATUSES_FETCH_FAIL, error });
    });
  };
}

export function cancelScheduledStatus(id) {
  return dispatch => {
    dispatch({ type: SCHEDULED_STATUSES_FETCH_REQUEST });

    api().delete(`/api/v1/scheduled_statuses/${id}`).then(() => {
      dispatch({
        type: SCHEDULED_STATUS_CANCEL_SUCCESS,
        id,
      });
    }).catch(error => {
      dispatch({ type: SCHEDULED_STATUSES_FETCH_FAIL, error });
    });
  };
}
