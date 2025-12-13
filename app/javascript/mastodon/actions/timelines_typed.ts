import { createAction } from '@reduxjs/toolkit';

import { usePendingItems as preferPendingItems } from 'mastodon/initial_state';

import { TIMELINE_NON_STATUS_MARKERS } from './timelines';

export function isNonStatusId(value: unknown) {
  return TIMELINE_NON_STATUS_MARKERS.includes(value as string | null);
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
