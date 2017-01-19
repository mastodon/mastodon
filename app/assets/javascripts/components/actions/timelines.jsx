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

export const TIMELINE_SCROLL_TOP = 'TIMELINE_SCROLL_TOP';

export function refreshTimelineSuccess(timeline, statuses, skipLoading) {
  return {
    type: TIMELINE_REFRESH_SUCCESS,
    timeline,
    statuses,
    skipLoading
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
    const reblogOf   = getState().getIn(['statuses', id, 'reblog'], null);

    dispatch({
      type: TIMELINE_DELETE,
      id,
      accountId,
      references,
      reblogOf
    });
  };
};

export function refreshTimelineRequest(timeline, id, skipLoading) {
  return {
    type: TIMELINE_REFRESH_REQUEST,
    timeline,
    id,
    skipLoading
  };
};

export function refreshTimeline(timeline, id = null) {
  return function (dispatch, getState) {
    const ids      = getState().getIn(['timelines', timeline, 'items'], Immutable.List());
    const newestId = ids.size > 0 ? ids.first() : null;

    let params      = '';
    let path        = timeline;
    let skipLoading = false;

    if (newestId !== null && getState().getIn(['timelines', timeline, 'loaded'])) {
      params      = `?since_id=${newestId}`;
      skipLoading = true;
    }

    if (id) {
      path = `${path}/${id}`
    }

    dispatch(refreshTimelineRequest(timeline, id, skipLoading));

    api(getState).get(`/api/v1/timelines/${path}${params}`).then(function (response) {
      dispatch(refreshTimelineSuccess(timeline, response.data, skipLoading));
    }).catch(function (error) {
      dispatch(refreshTimelineFail(timeline, error, skipLoading));
    });
  };
};

export function refreshTimelineFail(timeline, error, skipLoading) {
  return {
    type: TIMELINE_REFRESH_FAIL,
    timeline,
    error,
    skipLoading
  };
};

export function expandTimeline(timeline, id = null) {
  return (dispatch, getState) => {
    const lastId = getState().getIn(['timelines', timeline, 'items'], Immutable.List()).last();

    if (!lastId) {
      // If timeline is empty, don't try to load older posts since there are none
      return;
    }

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
    timeline
  };
};

export function expandTimelineSuccess(timeline, statuses) {
  return {
    type: TIMELINE_EXPAND_SUCCESS,
    timeline,
    statuses
  };
};

export function expandTimelineFail(timeline, error) {
  return {
    type: TIMELINE_EXPAND_FAIL,
    timeline,
    error
  };
};

export function scrollTopTimeline(timeline, top) {
  return {
    type: TIMELINE_SCROLL_TOP,
    timeline,
    top
  };
};
