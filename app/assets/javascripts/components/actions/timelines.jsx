import api from '../api'
import Immutable from 'immutable';

export const TIMELINE_UPDATE  = 'TIMELINE_UPDATE';
export const TIMELINE_DELETE  = 'TIMELINE_DELETE';

export const TIMELINE_REFRESH_REQUEST = 'TIMELINE_REFRESH_REQUEST';
export const TIMELINE_REFRESH_SUCCESS = 'TIMELINE_REFRESH_SUCCESS';
export const TIMELINE_REFRESH_FAIL    = 'TIMELINE_REFRESH_FAIL';

export const TIMELINE_EXPAND_REQUEST = 'TIMELINE_EXPAND_REQUEST';
export const TIMELINE_EXPAND_SUCCESS = 'TIMELINE_EXPAND_SUCCESS';
export const TIMELINE_EXPAND_FAIL    = 'TIMELINE_EXPAND_FAIL';

export function refreshTimelineSuccess(timeline, statuses, replace) {
  return {
    type: TIMELINE_REFRESH_SUCCESS,
    timeline: timeline,
    statuses: statuses,
    replace: replace
  };
};

export function updateTimeline(timeline, status) {
  return (dispatch, getState) => {
    const references = status.reblog ? getState().get('statuses').filter((item, itemId) => (itemId === status.reblog.id || item.get('reblog') === status.reblog.id)).map((_, itemId) => itemId) : [];

    dispatch({
      type: TIMELINE_UPDATE,
      timeline,
      status,
      references
    });
  };
};

export function deleteFromTimelines(id) {
  return (dispatch, getState) => {
    const accountId  = getState().getIn(['statuses', id, 'account']);
    const references = getState().get('statuses').filter(status => status.get('reblog') === id).map(status => [status.get('id'), status.get('account')]);

    dispatch({
      type: TIMELINE_DELETE,
      id,
      accountId,
      references
    });
  };
};

export function refreshTimelineRequest(timeline) {
  return {
    type: TIMELINE_REFRESH_REQUEST,
    timeline: timeline
  };
};

export function refreshTimeline(timeline, replace = false, id = null) {
  return function (dispatch, getState) {
    dispatch(refreshTimelineRequest(timeline));

    const ids      = getState().getIn(['timelines', timeline], Immutable.List());
    const newestId = ids.size > 0 ? ids.first() : null;

    let params = '';
    let path   = timeline;

    if (newestId !== null && !replace) {
      params = `?since_id=${newestId}`;
    }

    if (id) {
      path = `${path}/${id}`
    }

    api(getState).get(`/api/v1/timelines/${path}${params}`).then(function (response) {
      dispatch(refreshTimelineSuccess(timeline, response.data, replace));
    }).catch(function (error) {
      dispatch(refreshTimelineFail(timeline, error));
    });
  };
};

export function refreshTimelineFail(timeline, error) {
  return {
    type: TIMELINE_REFRESH_FAIL,
    timeline: timeline,
    error: error
  };
};

export function expandTimeline(timeline, id = null) {
  return (dispatch, getState) => {
    const lastId = getState().getIn(['timelines', timeline], Immutable.List()).last();

    dispatch(expandTimelineRequest(timeline));

    let path = timeline;

    if (id) {
      path = `${path}/${id}`
    }

    api(getState).get(`/api/v1/timelines/${path}?max_id=${lastId}`).then(response => {
      dispatch(expandTimelineSuccess(timeline, response.data));
    }).catch(error => {
      dispatch(expandTimelineFail(timeline, error));
    });
  };
};

export function expandTimelineRequest(timeline) {
  return {
    type: TIMELINE_EXPAND_REQUEST,
    timeline: timeline
  };
};

export function expandTimelineSuccess(timeline, statuses) {
  return {
    type: TIMELINE_EXPAND_SUCCESS,
    timeline: timeline,
    statuses: statuses
  };
};

export function expandTimelineFail(timeline, error) {
  return {
    type: TIMELINE_EXPAND_FAIL,
    timeline: timeline,
    error: error
  };
};
