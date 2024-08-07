import { createSelector } from '@reduxjs/toolkit';

import { compareId } from 'mastodon/compare_id';
import type { RootState } from 'mastodon/store';

export const selectUnreadNotificationGroupsCount = createSelector(
  [
    (s: RootState) => s.notificationGroups.lastReadId,
    (s: RootState) => s.notificationGroups.pendingGroups,
    (s: RootState) => s.notificationGroups.groups,
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

// Whether there is any unread notification according to the user-facing state
export const selectAnyPendingNotification = createSelector(
  [
    (s: RootState) => s.notificationGroups.readMarkerId,
    (s: RootState) => s.notificationGroups.groups,
  ],
  (notificationMarker, groups) => {
    return groups.some(
      (group) =>
        group.type !== 'gap' &&
        group.page_max_id &&
        compareId(group.page_max_id, notificationMarker) > 0,
    );
  },
);

export const selectPendingNotificationGroupsCount = createSelector(
  [(s: RootState) => s.notificationGroups.pendingGroups],
  (pendingGroups) =>
    pendingGroups.filter((group) => group.type !== 'gap').length,
);
