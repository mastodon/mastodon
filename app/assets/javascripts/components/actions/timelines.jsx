export const TIMELINE_SET    = 'TIMELINE_SET';
export const TIMELINE_UPDATE = 'TIMELINE_UPDATE';
export const TIMELINE_DELETE = 'TIMELINE_DELETE';

export function setTimeline(timeline, statuses) {
  return {
    type: TIMELINE_SET,
    timeline: timeline,
    statuses: statuses
  };
}

export function updateTimeline(timeline, status) {
  return {
    type: TIMELINE_UPDATE,
    timeline: timeline,
    status: status
  };
}

export function deleteFromTimelines(id) {
  return {
    type: TIMELINE_DELETE,
    id: id
  };
}
