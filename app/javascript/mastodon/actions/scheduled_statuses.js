import api from '../api';

export const SCHEDULED_STATUSES_FETCH_SUCCESS = 'SCHEDULED_STATUSES_FETCH_SUCCESS';
export const SCHEDULED_STATUS_CANCEL_SUCCESS  = 'SCHEDULED_STATUS_CANCEL_SUCCESS';

export const fetchScheduledStatuses = () => (dispatch) =>
  api().get('/api/v1/scheduled_statuses')
    .then(({ data }) => dispatch({ type: SCHEDULED_STATUSES_FETCH_SUCCESS, statuses: data }));

export const cancelScheduledStatus = (id) => (dispatch) =>
  api().delete(`/api/v1/scheduled_statuses/${id}`)
    .then(() => dispatch({ type: SCHEDULED_STATUS_CANCEL_SUCCESS, id }));

export const updateScheduledStatus = (id, scheduledAt) => () =>
  api().put(`/api/v1/scheduled_statuses/${id}`, { scheduled_at: scheduledAt });