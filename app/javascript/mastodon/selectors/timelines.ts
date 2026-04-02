import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import type { TimelineParams } from '../actions/timelines_typed';
import { timelineKey } from '../actions/timelines_typed';
import { createAppSelector } from '../store';

interface TimelineShape {
  unread: number;
  online: boolean;
  top: boolean;
  isLoading: boolean;
  hasMore: boolean;
  pendingItems: ImmutableList<string>;
  items: ImmutableList<string>;
}

type TimelinesState = ImmutableMap<string, ImmutableMap<string, unknown>>;

const emptyList = ImmutableList<string>();

export const selectTimelineByKey = createAppSelector(
  [(_, key: string) => key, (state) => state.timelines as TimelinesState],
  (key, timelines) => toTypedTimeline(timelines.get(key)),
);

export const selectTimelineByParams = createAppSelector(
  [
    (_, params: TimelineParams) => timelineKey(params),
    (state) => state.timelines as TimelinesState,
  ],
  (key, timelines) => toTypedTimeline(timelines.get(key)),
);

export function toTypedTimeline(timeline?: ImmutableMap<string, unknown>) {
  if (!timeline) {
    return null;
  }
  return {
    unread: timeline.get('unread', 0) as number,
    online: !!timeline.get('online', false),
    top: !!timeline.get('top', false),
    isLoading: !!timeline.get('isLoading', true),
    hasMore: !!timeline.get('hasMore', false),
    pendingItems: timeline.get(
      'pendingItems',
      emptyList,
    ) as ImmutableList<string>,
    items: timeline.get('items', emptyList) as ImmutableList<string>,
  } satisfies TimelineShape;
}
