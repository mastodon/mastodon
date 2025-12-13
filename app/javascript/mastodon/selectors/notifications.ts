import { createSelector } from '@reduxjs/toolkit';

import { compareId } from 'mastodon/compare_id';
import type { NotificationGroup } from 'mastodon/models/notification_group';
import type { NotificationGap } from 'mastodon/reducers/notification_groups';
import type { RootState } from 'mastodon/store';

import {
  selectSettingsNotificationsExcludedTypes,
  selectSettingsNotificationsQuickFilterActive,
  selectSettingsNotificationsQuickFilterShow,
} from './settings';

const filterNotificationsByAllowedTypes = (
  showFilterBar: boolean,
  allowedType: string,
  excludedTypes: string[],
  notifications: (NotificationGroup | NotificationGap)[],
) => {
  if (!showFilterBar || allowedType === 'all') {
    // used if user changed the notification settings after loading the notifications from the server
    // otherwise a list of notifications will come pre-filtered from the backend
    // we need to turn it off for FilterBar in order not to block ourselves from seeing a specific category
    return notifications.filter(
      (item) => item.type === 'gap' || !excludedTypes.includes(item.type),
    );
  }
  return notifications.filter(
    (item) =>
      item.type === 'gap' ||
      allowedType === item.type ||
      (allowedType === 'mention' && item.type === 'quote'),
  );
};

export const selectNotificationGroups = createSelector(
  [
    selectSettingsNotificationsQuickFilterShow,
    selectSettingsNotificationsQuickFilterActive,
    selectSettingsNotificationsExcludedTypes,
    (state: RootState) => state.notificationGroups.groups,
  ],
  filterNotificationsByAllowedTypes,
);

const selectPendingNotificationGroups = createSelector(
  [
    selectSettingsNotificationsQuickFilterShow,
    selectSettingsNotificationsQuickFilterActive,
    selectSettingsNotificationsExcludedTypes,
    (state: RootState) => state.notificationGroups.pendingGroups,
  ],
  filterNotificationsByAllowedTypes,
);

export const selectUnreadNotificationGroupsCount = createSelector(
  [
    (s: RootState) => s.notificationGroups.lastReadId,
    selectNotificationGroups,
    selectPendingNotificationGroups,
  ],
  (notificationMarker, groups, pendingGroups) => {
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
    selectNotificationGroups,
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
  [selectPendingNotificationGroups],
  (pendingGroups) =>
    pendingGroups.filter((group) => group.type !== 'gap').length,
);
