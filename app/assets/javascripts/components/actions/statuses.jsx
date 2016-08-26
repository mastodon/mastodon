import fetch from 'isomorphic-fetch'

export const SET_TIMELINE = 'SET_TIMELINE';
export const ADD_STATUS   = 'ADD_STATUS';

export const PUBLISH       = 'PUBLISH';
export const PUBLISH_START = 'PUBLISH_START';
export const PUBLISH_SUCC  = 'PUBLISH_SUCC';
export const PUBLISH_ERROR = 'PUBLISH_ERROR';

export function setTimeline(timeline, statuses) {
  return {
    type: SET_TIMELINE,
    timeline: timeline,
    statuses: statuses
  };
}

export function addStatus(timeline, status) {
  return {
    type: ADD_STATUS,
    timeline: timeline,
    status: status
  };
}

export function publishStart() {
  return {
    type: PUBLISH_START
  };
}

export function publishError(error) {
  return {
    type: PUBLISH_ERROR,
    error: error
  };
}

export function publishSucc(status) {
  return {
    type: PUBLISH_SUCC,
    status: status
  };
}

export function publish(text, in_reply_to_id) {
  return function (dispatch, getState) {
    const access_token = getState().getIn(['meta', 'access_token']);

    var data = new FormData();

    data.append('status', text);

    if (in_reply_to_id !== null) {
      data.append('in_reply_to_id', in_reply_to_id);
    }

    dispatch(publishStart());

    return fetch('/api/statuses', {
      method: 'POST',

      headers: {
        'Authorization': `Bearer ${access_token}`
      },

      body: data
    }).then(function (response) {
      return response.json();
    }).then(function (json) {
      if (json.error) {
        dispatch(publishError(json.error));
      } else {
        dispatch(publishSucc(json));
      }
    }).catch(function (error) {
      dispatch(publishError(error));
    });
  };
}
