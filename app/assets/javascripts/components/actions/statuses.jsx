import fetch from 'isomorphic-fetch'

export const SET_TIMELINE = 'SET_TIMELINE';
export const ADD_STATUS   = 'ADD_STATUS';
export const PUBLISH      = 'PUBLISH';

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

export function publish(text, in_reply_to_id) {
  return function (dispatch) {
    return fetch('/api/statuses', {
      method: 'POST'
    }).then(function (response) {
      return response.json();
    }).then(function (json) {
      console.log(json);
    });
  };
}
