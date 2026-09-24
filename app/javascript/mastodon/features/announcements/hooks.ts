import { useEffect } from 'react';

import type {
  List as ImmutableList,
  Record as ImmutableRecord,
} from 'immutable';

import {
  fetchAnnouncements,
  showAnnouncements,
} from '@/mastodon/actions/announcements';
import type { ApiAnnouncementJSON } from '@/mastodon/api_types/announcements';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

type AnnouncementItem = ImmutableRecord<ApiAnnouncementJSON>;

type AnnouncementsState = ImmutableRecord<{
  items: ImmutableList<AnnouncementItem>;
  isLoading: boolean;
  show: boolean;
}>;

export function useHasAnnouncements({
  fetch = true,
}: { fetch?: boolean } = {}) {
  const dispatch = useAppDispatch();
  const hasAnnouncements = useAppSelector(
    (state) =>
      !(state.announcements as AnnouncementsState).get('items').isEmpty(),
  );
  const shouldShowAnnouncements = useAppSelector((state) =>
    (state.announcements as AnnouncementsState).get('show'),
  );
  const unreadAnnouncementCount = useAppSelector((state) =>
    (state.announcements as AnnouncementsState)
      .get('items')
      .count((item) => !item.get('read')),
  );
  const hasUnreadAnnouncements = !!unreadAnnouncementCount;

  useEffect(() => {
    if (hasUnreadAnnouncements && isRedesignEnabled()) {
      dispatch(showAnnouncements());
    }
  }, [hasUnreadAnnouncements, dispatch]);

  useEffect(() => {
    const timeout = setTimeout(() => {
      if (fetch) {
        dispatch(fetchAnnouncements());
      }
    }, 700);

    return () => {
      clearTimeout(timeout);
    };
  }, [fetch, dispatch]);

  return {
    hasAnnouncements,
    hasUnreadAnnouncements,
    shouldShowAnnouncements,
    unreadAnnouncementCount,
  };
}
