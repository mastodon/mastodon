import type { Map as ImmutableMap } from 'immutable';

import type { TimelineParams } from '../actions/timelines_typed';
import { timelineKey } from '../actions/timelines_typed';
import { createAppSelector } from '../store';

export interface TimelineState {
  unread: number;
  online: boolean;
  top: boolean;
  isLoading: boolean;
  hasMore: boolean;
  pendingItems: string[];
  items: string[];
}

export const selectTimelineByKey = createAppSelector(
  [
    (_, key: string) => key,
    (state) =>
      state.timelines as ImmutableMap<string, ImmutableMap<string, unknown>>,
  ],
  (key, timelines) => {
    return timelines.get(key)?.toJSON() as TimelineState | undefined;
  },
);

export const selectTimelineByParams = createAppSelector(
  [
    (_, params: TimelineParams) => timelineKey(params),
    (state) =>
      state.timelines as ImmutableMap<string, ImmutableMap<string, unknown>>,
  ],
  (key, timelines) => {
    return timelines.get(key)?.toJSON() as TimelineState | undefined;
  },
);
