import api from '../api'

export const TIMELINE_UPDATE  = 'TIMELINE_UPDATE';
export const TIMELINE_DELETE  = 'TIMELINE_DELETE';

export const TIMELINE_REFRESH_REQUEST = 'TIMELINE_REFRESH_REQUEST';
export const TIMELINE_REFRESH_SUCCESS = 'TIMELINE_REFRESH_SUCCESS';
export const TIMELINE_REFRESH_FAIL    = 'TIMELINE_REFRESH_FAIL';

export const TIMELINE_EXPAND_REQUEST = 'TIMELINE_EXPAND_REQUEST';
export const TIMELINE_EXPAND_SUCCESS = 'TIMELINE_EXPAND_SUCCESS';
export const TIMELINE_EXPAND_FAIL    = 'TIMELINE_EXPAND_FAIL';

export function refreshTimelineSuccess(timeline, statuses) {
  return {
    type: TIMELINE_REFRESH_SUCCESS,
    timeline: timeline,
    statuses: statuses
  };
};

export function updateTimeline(timeline, status) {
  return {
    type: TIMELINE_UPDATE,
    timeline: timeline,
    status: status
  };
};

export function deleteFromTimelines(id) {
  return {
    type: TIMELINE_DELETE,
    id: id
  };
};

export function refreshTimelineRequest(timeline) {
  return {
    type: TIMELINE_REFRESH_REQUEST,
    timeline: timeline
  };
};

export function refreshTimeline(timeline) {
  return function (dispatch, getState) {
    dispatch(refreshTimelineRequest(timeline));

    api(getState).get(`/api/v1/statuses/${timeline}`).then(function (response) {
      dispatch(refreshTimelineSuccess(timeline, response.data));
    }).catch(function (error) {
      console.error(error);
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

export function expandTimeline(timeline) {
  return (dispatch, getState) => {
    const lastId = getState().getIn(['timelines', timeline]).last();

    dispatch(expandTimelineRequest(timeline));

    api(getState).get(`/api/v1/statuses/${timeline}?max_id=${lastId}`).then(response => {
      dispatch(expandTimelineSuccess(timeline, response.data));
    }).catch(error => {
      console.error(error);
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
