import { createSelector } from '@reduxjs/toolkit';

import { compareId } from 'mastodon/compare_id';
import type { RootState } from 'mastodon/store';

export const selectUnreadNotificationsGroupsCount = createSelector(
  [
    (s: RootState) => s.markers.notifications,
    (s: RootState) => s.notificationsGroups.pendingGroups,
    (s: RootState) => s.notificationsGroups.groups,
  ],
  (notificationMarker, pendingGroups, groups) => {
    return (
      groups.filter(
        (group) =>
          group.type !== 'gap' &&
          group.page_max_id &&
          compareId(group.page_max_id, notificationMarker) > 0,
      ).length +
      pendingGroups.filter(
        (group) =>
          group.type !== 'gap' &&
          group.page_max_id &&
          compareId(group.page_max_id, notificationMarker) > 0,
      ).length
    );
  },
);

export const selectPendingNotificationsGroupsCount = createSelector(
  [(s: RootState) => s.notificationsGroups.pendingGroups],
  (pendingGroups) =>
    pendingGroups.filter((group) => group.type !== 'gap').length,
);
