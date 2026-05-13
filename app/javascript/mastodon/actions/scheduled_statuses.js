import { defineMessages } from 'react-intl';

import api, { getLinks } from '../api';

import { showAlert, showAlertForError } from './alerts';
import {
  ensureComposeIsVisible,
  redraftScheduledStatus,
} from './compose';

export const SCHEDULED_STATUSES_FETCH_REQUEST =
  'SCHEDULED_STATUSES_FETCH_REQUEST';
export const SCHEDULED_STATUSES_FETCH_SUCCESS =
  'SCHEDULED_STATUSES_FETCH_SUCCESS';
export const SCHEDULED_STATUSES_FETCH_FAIL = 'SCHEDULED_STATUSES_FETCH_FAIL';

export const SCHEDULED_STATUSES_EXPAND_REQUEST =
  'SCHEDULED_STATUSES_EXPAND_REQUEST';
export const SCHEDULED_STATUSES_EXPAND_SUCCESS =
  'SCHEDULED_STATUSES_EXPAND_SUCCESS';
export const SCHEDULED_STATUSES_EXPAND_FAIL = 'SCHEDULED_STATUSES_EXPAND_FAIL';

export const SCHEDULED_STATUS_UPDATE_REQUEST =
  'SCHEDULED_STATUS_UPDATE_REQUEST';
export const SCHEDULED_STATUS_UPDATE_SUCCESS =
  'SCHEDULED_STATUS_UPDATE_SUCCESS';
export const SCHEDULED_STATUS_UPDATE_FAIL = 'SCHEDULED_STATUS_UPDATE_FAIL';

export const SCHEDULED_STATUS_DELETE_REQUEST =
  'SCHEDULED_STATUS_DELETE_REQUEST';
export const SCHEDULED_STATUS_DELETE_SUCCESS =
  'SCHEDULED_STATUS_DELETE_SUCCESS';
export const SCHEDULED_STATUS_DELETE_FAIL = 'SCHEDULED_STATUS_DELETE_FAIL';

const messages = defineMessages({
  updated: {
    id: 'scheduled_statuses.updated',
    defaultMessage: 'Schedule updated.',
  },
  deleted: {
    id: 'scheduled_statuses.deleted',
    defaultMessage: 'Scheduled post deleted.',
  },
});

export function fetchScheduledStatuses() {
  return (dispatch, getState) => {
    if (getState().getIn(['scheduled_statuses', 'isLoading'])) {
      return;
    }

    dispatch(fetchScheduledStatusesRequest());

    api()
      .get('/api/v1/scheduled_statuses')
      .then((response) => {
        const next = getLinks(response).refs.find((link) => link.rel === 'next');

        dispatch(
          fetchScheduledStatusesSuccess(response.data, next ? next.uri : null),
        );
      })
      .catch((error) => {
        dispatch(fetchScheduledStatusesFail(error));
        dispatch(showAlertForError(error));
      });
  };
}

export const fetchScheduledStatusesRequest = () => ({
  type: SCHEDULED_STATUSES_FETCH_REQUEST,
  skipLoading: true,
});

export const fetchScheduledStatusesSuccess = (statuses, next) => ({
  type: SCHEDULED_STATUSES_FETCH_SUCCESS,
  statuses,
  next,
  skipLoading: true,
});

export const fetchScheduledStatusesFail = (error) => ({
  type: SCHEDULED_STATUSES_FETCH_FAIL,
  error,
  skipLoading: true,
});

export function expandScheduledStatuses() {
  return (dispatch, getState) => {
    const url = getState().getIn(['scheduled_statuses', 'next'], null);

    if (url === null || getState().getIn(['scheduled_statuses', 'isLoading'])) {
      return;
    }

    dispatch(expandScheduledStatusesRequest());

    api()
      .get(url)
      .then((response) => {
        const next = getLinks(response).refs.find((link) => link.rel === 'next');

        dispatch(
          expandScheduledStatusesSuccess(response.data, next ? next.uri : null),
        );
      })
      .catch((error) => {
        dispatch(expandScheduledStatusesFail(error));
        dispatch(showAlertForError(error));
      });
  };
}

export const expandScheduledStatusesRequest = () => ({
  type: SCHEDULED_STATUSES_EXPAND_REQUEST,
});

export const expandScheduledStatusesSuccess = (statuses, next) => ({
  type: SCHEDULED_STATUSES_EXPAND_SUCCESS,
  statuses,
  next,
});

export const expandScheduledStatusesFail = (error) => ({
  type: SCHEDULED_STATUSES_EXPAND_FAIL,
  error,
});

export function updateScheduledStatus(id, scheduledAt) {
  return (dispatch) => {
    dispatch(updateScheduledStatusRequest(id));

    return api()
      .put(`/api/v1/scheduled_statuses/${id}`, {
        scheduled_at: scheduledAt,
      })
      .then((response) => {
        dispatch(updateScheduledStatusSuccess(response.data));
        dispatch(showAlert({ message: messages.updated }));
        return response;
      })
      .catch((error) => {
        dispatch(updateScheduledStatusFail(id, error));
        dispatch(showAlertForError(error));
        throw error;
      });
  };
}

export const updateScheduledStatusRequest = (id) => ({
  type: SCHEDULED_STATUS_UPDATE_REQUEST,
  id,
});

export const updateScheduledStatusSuccess = (status) => ({
  type: SCHEDULED_STATUS_UPDATE_SUCCESS,
  status,
});

export const updateScheduledStatusFail = (id, error) => ({
  type: SCHEDULED_STATUS_UPDATE_FAIL,
  id,
  error,
});

export function deleteScheduledStatus(id) {
  return (dispatch) => {
    dispatch(deleteScheduledStatusRequest(id));

    return api()
      .delete(`/api/v1/scheduled_statuses/${id}`)
      .then((response) => {
        dispatch(deleteScheduledStatusSuccess(id));
        dispatch(showAlert({ message: messages.deleted }));
        return response;
      })
      .catch((error) => {
        dispatch(deleteScheduledStatusFail(id, error));
        dispatch(showAlertForError(error));
        throw error;
      });
  };
}

export function editScheduledStatus(scheduledStatus) {
  return (dispatch, getState) => {
    const { id } = scheduledStatus;

    dispatch(deleteScheduledStatusRequest(id));

    return api()
      .delete(`/api/v1/scheduled_statuses/${id}`)
      .then((response) => {
        dispatch(deleteScheduledStatusSuccess(id));
        dispatch(redraftScheduledStatus(scheduledStatus));
        ensureComposeIsVisible(getState);
        return response;
      })
      .catch((error) => {
        dispatch(deleteScheduledStatusFail(id, error));
        dispatch(showAlertForError(error));
        throw error;
      });
  };
}

export const deleteScheduledStatusRequest = (id) => ({
  type: SCHEDULED_STATUS_DELETE_REQUEST,
  id,
});

export const deleteScheduledStatusSuccess = (id) => ({
  type: SCHEDULED_STATUS_DELETE_SUCCESS,
  id,
});

export const deleteScheduledStatusFail = (id, error) => ({
  type: SCHEDULED_STATUS_DELETE_FAIL,
  id,
  error,
});
