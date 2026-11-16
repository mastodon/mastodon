import { useEffect } from 'react';

import type { Map as ImmutableMap } from 'immutable';

import { fetchFollowRequests } from '@/mastodon/actions/accounts';
import { fetchLists } from '@/mastodon/actions/lists';
import { fetchFollowedHashtags } from '@/mastodon/actions/tags_typed';
import { useIdentity } from '@/mastodon/identity_context';
import { getOrderedLists } from '@/mastodon/selectors/lists';
import { selectUnreadNotificationGroupsCount } from '@/mastodon/selectors/notifications';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { useHasAnnouncements } from '../announcements/hooks';

export function useCustomFeeds() {
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const customFeeds = useAppSelector((state) => getOrderedLists(state));

  useEffect(() => {
    if (signedIn) {
      void dispatch(fetchLists());
    }
  }, [dispatch, signedIn]);

  return {
    customFeeds,
  };
}

export function useFollowedHashtags() {
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const { tags, stale } = useAppSelector((state) => state.followedTags);

  useEffect(() => {
    if (stale && signedIn) {
      void dispatch(fetchFollowedHashtags());
    }
  }, [dispatch, stale, signedIn]);

  return { followedHashtags: tags };
}

export function useFollowRequestsCount({
  fetch = true,
}: { fetch?: boolean } = {}) {
  const followRequestsCount = useAppSelector(
    (state) =>
      (
        state.user_lists.getIn(['follow_requests', 'items']) as
          | ImmutableMap<string, unknown>
          | undefined
      )?.size ?? 0,
  );
  const dispatch = useAppDispatch();

  useEffect(() => {
    if (fetch) {
      dispatch(fetchFollowRequests());
    }
  }, [dispatch, fetch]);

  return followRequestsCount;
}

export function useNotificationsCount() {
  const unreadNotificationsCount = useAppSelector(
    selectUnreadNotificationGroupsCount,
  );
  const { signedIn } = useIdentity();
  const followRequestsCount = useFollowRequestsCount({ fetch: signedIn });

  const { unreadAnnouncementCount } = useHasAnnouncements({ fetch: signedIn });

  return (
    unreadNotificationsCount + followRequestsCount + unreadAnnouncementCount
  );
}
