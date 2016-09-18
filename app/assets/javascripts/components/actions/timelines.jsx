import api from '../api'

export const TIMELINE_SET     = 'TIMELINE_SET';
export const TIMELINE_UPDATE  = 'TIMELINE_UPDATE';
export const TIMELINE_DELETE  = 'TIMELINE_DELETE';

export const TIMELINE_REFRESH_REQUEST = 'TIMELINE_REFRESH_REQUEST';
export const TIMELINE_REFRESH_SUCCESS = 'TIMELINE_REFRESH_SUCCESS';
export const TIMELINE_REFRESH_FAIL    = 'TIMELINE_REFRESH_FAIL';

export const TIMELINE_EXPAND_REQUEST = 'TIMELINE_EXPAND_REQUEST';
export const TIMELINE_EXPAND_SUCCESS = 'TIMELINE_EXPAND_SUCCESS';
export const TIMELINE_EXPAND_FAIL    = 'TIMELINE_EXPAND_FAIL';

export function setTimeline(timeline, statuses) {
  return {
    type: TIMELINE_SET,
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

    api(getState).get(`/api/statuses/${timeline}`).then(function (response) {
      dispatch(refreshTimelineSuccess(timeline, response.data));
    }).catch(function (error) {
      dispatch(refreshTimelineFail(timeline, error));
    });
  };
};

export function refreshTimelineSuccess(timeline, statuses) {
  return function (dispatch) {
    dispatch(setTimeline(timeline, statuses));
  };
};

export function refreshTimelineFail(timeline, error) {
  return {
    type: TIMELINE_REFRESH_FAIL,
    timeline: timeline,
    error: error
  };
};
