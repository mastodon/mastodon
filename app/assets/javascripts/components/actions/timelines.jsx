export const TIMELINE_SET    = 'TIMELINE_SET';
export const TIMELINE_UPDATE = 'TIMELINE_UPDATE';


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
