import { useEffect } from 'react';

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

export function useHasAnnouncements() {
  const dispatch = useAppDispatch();
  const hasAnnouncements = useAppSelector(
    (state) =>
      !(state.announcements as AnnouncementsState).get('items').isEmpty(),
  );
  const showAnnouncements = useAppSelector((state) =>
    (state.announcements as AnnouncementsState).get('show'),
  );
  const unreadAnnouncementCount = useAppSelector((state) =>
    (state.announcements as AnnouncementsState)
      .get('items')
      .count((item) => !item.get('read')),
  );

  useEffect(() => {
    const timeout = setTimeout(() => {
      dispatch(fetchAnnouncements());
    }, 700);

    return () => {
      clearTimeout(timeout);
    };
  }, [dispatch]);

  return { hasAnnouncements, showAnnouncements, unreadAnnouncementCount };
}
