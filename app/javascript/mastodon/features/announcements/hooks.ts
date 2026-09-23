import { useEffect, useState } from 'react';

import type {
  List as ImmutableList,
  Record as ImmutableRecord,
} from 'immutable';

import { fetchAnnouncements } from '@/mastodon/actions/announcements';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

type AnnouncementItem = ImmutableRecord<{
  id: string;
  starts_at: string;
  published_at: string;
  read: boolean;
}>;

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

  // Announcements display is transient – it's toggled on when
  // there are unread announcements or the `show` Redux state is
  // enabled, but resets to hidden when the page is left (by virtue
  // of React simply losing this state).
  const [showAnnouncements, setShowAnnouncements] = useState(false);
  if (
    (hasUnreadAnnouncements || shouldShowAnnouncements) &&
    !showAnnouncements
  ) {
    setShowAnnouncements(true);
  }

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
    showAnnouncements,
    unreadAnnouncementCount,
  };
}
