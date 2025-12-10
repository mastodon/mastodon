import { createAction } from '@reduxjs/toolkit';

import { usePendingItems as preferPendingItems } from 'mastodon/initial_state';

import { TIMELINE_WRAPSTODON } from '../reducers/slices/annual_report';

import { TIMELINE_GAP, TIMELINE_SUGGESTIONS } from './timelines';

export const TIMELINE_NON_STATUS_MARKERS = [
  TIMELINE_GAP,
  TIMELINE_SUGGESTIONS,
  TIMELINE_WRAPSTODON,
] as const;
type TimelineNonStatusMarker = (typeof TIMELINE_NON_STATUS_MARKERS)[number];

export function isNonStatusId(
  value: unknown,
): value is TimelineNonStatusMarker {
  return TIMELINE_NON_STATUS_MARKERS.includes(value as TimelineNonStatusMarker);
}

export const disconnectTimeline = createAction(
  'timeline/disconnect',
  ({ timeline }: { timeline: string }) => ({
    payload: {
      timeline,
      usePendingItems: preferPendingItems,
    },
  }),
);

export const timelineDelete = createAction<{
  statusId: string;
  accountId: string;
  references: string[];
  reblogOf: string | null;
}>('timelines/delete');
