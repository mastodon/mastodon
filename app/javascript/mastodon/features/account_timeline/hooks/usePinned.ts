import { useEffect, useMemo } from 'react';

import { TIMELINE_PINNED_VIEW_ALL } from '@/mastodon/actions/timelines';
import {
  expandTimelineByKey,
  timelineKey,
} from '@/mastodon/actions/timelines_typed';
import { selectTimelineByKey } from '@/mastodon/selectors/timelines';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { useAccountContext } from './useAccountContext';

export function usePinnedStatusIds({
  accountId,
  tagged,
  forceEmptyState = false,
}: {
  accountId: string;
  tagged?: string;
  forceEmptyState?: boolean;
}) {
  const pinnedKey = timelineKey({
    type: 'account',
    userId: accountId,
    tagged,
    pinned: true,
    replies: true,
  });

  const dispatch = useAppDispatch();
  useEffect(() => {
    dispatch(expandTimelineByKey({ key: pinnedKey }));
  }, [dispatch, pinnedKey]);

  const pinnedTimeline = useAppSelector((state) =>
    selectTimelineByKey(state, pinnedKey),
  );

  const { showAllPinned } = useAccountContext();

  const pinnedTimelineItems = pinnedTimeline?.items; // Make a const to avoid the React Compiler complaining.
  const pinnedStatusIds = useMemo(() => {
    if (!pinnedTimelineItems || forceEmptyState) {
      return undefined;
    }

    if (pinnedTimelineItems.size <= 1 || showAllPinned) {
      return pinnedTimelineItems;
    }
    return pinnedTimelineItems.slice(0, 1).push(TIMELINE_PINNED_VIEW_ALL);
  }, [forceEmptyState, pinnedTimelineItems, showAllPinned]);

  return {
    statusIds: pinnedStatusIds,
    isLoading: !!pinnedTimeline?.isLoading,
    showAllPinned,
  };
}
