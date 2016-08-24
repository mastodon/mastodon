export const SET_TIMELINE = 'SET_TIMELINE';
export const ADD_STATUS   = 'ADD_STATUS';

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
