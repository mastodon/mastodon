import { createSelector } from '@reduxjs/toolkit';

import { compareId } from 'mastodon/compare_id';
import type { RootState } from 'mastodon/store';

export const selectUnreadNotificationsGroupsCount = createSelector(
  [
    (s: RootState) => s.markers.notifications,
    (s: RootState) => s.notificationsGroups.groups,
  ],
  (notificationMarker, groups) => {
    return groups.filter(
      (group) =>
        group.type !== 'gap' &&
        group.page_max_id &&
        compareId(group.page_max_id, notificationMarker) > 0,
    ).length;
  },
);
