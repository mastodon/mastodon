import { createAction } from '@reduxjs/toolkit';

import {
  apiClearNotifications,
  apiFetchNotificationGroups,
} from 'mastodon/api/notifications';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type {
  ApiNotificationGroupJSON,
  ApiNotificationJSON,
  NotificationType,
} from 'mastodon/api_types/notifications';
import { allNotificationTypes } from 'mastodon/api_types/notifications';
import type { ApiStatusJSON } from 'mastodon/api_types/statuses';
import { usePendingItems } from 'mastodon/initial_state';
import type { NotificationGap } from 'mastodon/reducers/notification_groups';
import {
  selectSettingsNotificationsExcludedTypes,
  selectSettingsNotificationsGroupFollows,
  selectSettingsNotificationsQuickFilterActive,
  selectSettingsNotificationsShows,
} from 'mastodon/selectors/settings';
import type { AppDispatch, RootState } from 'mastodon/store';
import {
  createAppAsyncThunk,
  createDataLoadingThunk,
} from 'mastodon/store/typed_functions';

import { importFetchedAccounts, importFetchedStatuses } from './importer';
import { NOTIFICATIONS_FILTER_SET } from './notifications';
import { saveSettings } from './settings';

function excludeAllTypesExcept(filter: string) {
  return allNotificationTypes.filter((item) => item !== filter);
}

function getExcludedTypes(state: RootState) {
  const activeFilter = selectSettingsNotificationsQuickFilterActive(state);

  return activeFilter === 'all'
    ? selectSettingsNotificationsExcludedTypes(state)
    : excludeAllTypesExcept(activeFilter);
}

function dispatchAssociatedRecords(
  dispatch: AppDispatch,
  notifications: ApiNotificationGroupJSON[] | ApiNotificationJSON[],
) {
  const fetchedAccounts: ApiAccountJSON[] = [];
  const fetchedStatuses: ApiStatusJSON[] = [];

  notifications.forEach((notification) => {
    if (notification.type === 'admin.report') {
      fetchedAccounts.push(notification.report.target_account);
    }

    if (notification.type === 'moderation_warning') {
      fetchedAccounts.push(notification.moderation_warning.target_account);
    }

    if ('status' in notification && notification.status) {
      fetchedStatuses.push(notification.status);
    }
  });

  if (fetchedAccounts.length > 0)
    dispatch(importFetchedAccounts(fetchedAccounts));

  if (fetchedStatuses.length > 0)
    dispatch(importFetchedStatuses(fetchedStatuses));
}

function selectNotificationGroupedTypes(state: RootState) {
  const types: NotificationType[] = ['favourite', 'reblog'];

  if (selectSettingsNotificationsGroupFollows(state)) types.push('follow');

  return types;
}

export const fetchNotifications = createDataLoadingThunk(
  'notificationGroups/fetch',
  async (_params, { getState }) =>
    apiFetchNotificationGroups({
      grouped_types: selectNotificationGroupedTypes(getState()),
      exclude_types: getExcludedTypes(getState()),
    }),
  ({ notifications, accounts, statuses }, { dispatch }) => {
    dispatch(importFetchedAccounts(accounts));
    dispatch(importFetchedStatuses(statuses));
    dispatchAssociatedRecords(dispatch, notifications);
    const payload: (ApiNotificationGroupJSON | NotificationGap)[] =
      notifications;

    // TODO: might be worth not using gaps for that…
    // if (nextLink) payload.push({ type: 'gap', loadUrl: nextLink.uri });
    if (notifications.length > 1)
      payload.push({ type: 'gap', maxId: notifications.at(-1)?.page_min_id });

    return payload;
    // dispatch(submitMarkers());
  },
);

export const fetchNotificationsGap = createDataLoadingThunk(
  'notificationGroups/fetchGap',
  async (params: { gap: NotificationGap }, { getState }) =>
    apiFetchNotificationGroups({
      grouped_types: selectNotificationGroupedTypes(getState()),
      max_id: params.gap.maxId,
      exclude_types: getExcludedTypes(getState()),
    }),
  ({ notifications, accounts, statuses }, { dispatch }) => {
    dispatch(importFetchedAccounts(accounts));
    dispatch(importFetchedStatuses(statuses));
    dispatchAssociatedRecords(dispatch, notifications);

    return { notifications };
  },
);

export const pollRecentNotifications = createDataLoadingThunk(
  'notificationGroups/pollRecentNotifications',
  async (_params, { getState }) => {
    return apiFetchNotificationGroups({
      grouped_types: selectNotificationGroupedTypes(getState()),
      max_id: undefined,
      exclude_types: getExcludedTypes(getState()),
      // In slow mode, we don't want to include notifications that duplicate the already-displayed ones
      since_id: usePendingItems
        ? getState().notificationGroups.groups.find(
            (group) => group.type !== 'gap',
          )?.page_max_id
        : undefined,
    });
  },
  ({ notifications, accounts, statuses }, { dispatch }) => {
    dispatch(importFetchedAccounts(accounts));
    dispatch(importFetchedStatuses(statuses));
    dispatchAssociatedRecords(dispatch, notifications);

    return { notifications };
  },
);

export const processNewNotificationForGroups = createAppAsyncThunk(
  'notificationGroups/processNew',
  (notification: ApiNotificationJSON, { dispatch, getState }) => {
    const state = getState();
    const activeFilter = selectSettingsNotificationsQuickFilterActive(state);
    const notificationShows = selectSettingsNotificationsShows(state);

    const showInColumn =
      activeFilter === 'all'
        ? notificationShows[notification.type]
        : activeFilter === notification.type;

    if (!showInColumn) return;

    if (
      (notification.type === 'mention' || notification.type === 'update') &&
      notification.status?.filtered
    ) {
      const filters = notification.status.filtered.filter((result) =>
        result.filter.context.includes('notifications'),
      );

      if (filters.some((result) => result.filter.filter_action === 'hide')) {
        return;
      }
    }

    dispatchAssociatedRecords(dispatch, [notification]);

    return {
      notification,
      groupedTypes: selectNotificationGroupedTypes(state),
    };
  },
);

export const loadPending = createAction('notificationGroups/loadPending');

export const updateScrollPosition = createAppAsyncThunk(
  'notificationGroups/updateScrollPosition',
  ({ top }: { top: boolean }, { dispatch, getState }) => {
    if (
      top &&
      getState().notificationGroups.mergedNotifications === 'needs-reload'
    ) {
      void dispatch(fetchNotifications());
    }

    return { top };
  },
);

export const setNotificationsFilter = createAppAsyncThunk(
  'notifications/filter/set',
  ({ filterType }: { filterType: string }, { dispatch }) => {
    dispatch({
      type: NOTIFICATIONS_FILTER_SET,
      path: ['notifications', 'quickFilter', 'active'],
      value: filterType,
    });
    void dispatch(fetchNotifications());
    dispatch(saveSettings());
  },
);

export const clearNotifications = createDataLoadingThunk(
  'notifications/clear',
  () => apiClearNotifications(),
);

export const markNotificationsAsRead = createAction(
  'notificationGroups/markAsRead',
);

export const mountNotifications = createAppAsyncThunk(
  'notificationGroups/mount',
  (_, { dispatch, getState }) => {
    const state = getState();

    if (
      state.notificationGroups.mounted === 0 &&
      state.notificationGroups.mergedNotifications === 'needs-reload'
    ) {
      void dispatch(fetchNotifications());
    }
  },
);

export const unmountNotifications = createAction('notificationGroups/unmount');

export const refreshStaleNotificationGroups = createAppAsyncThunk<{
  deferredRefresh: boolean;
}>('notificationGroups/refreshStale', (_, { dispatch, getState }) => {
  const state = getState();

  if (
    state.notificationGroups.scrolledToTop ||
    !state.notificationGroups.mounted
  ) {
    void dispatch(fetchNotifications());
    return { deferredRefresh: false };
  }

  return { deferredRefresh: true };
});
