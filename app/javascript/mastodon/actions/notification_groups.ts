import { createAction } from '@reduxjs/toolkit';

import {
  apiClearNotifications,
  apiFetchNotifications,
} from 'mastodon/api/notifications';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type {
  ApiNotificationGroupJSON,
  ApiNotificationJSON,
} from 'mastodon/api_types/notifications';
import { allNotificationTypes } from 'mastodon/api_types/notifications';
import type { ApiStatusJSON } from 'mastodon/api_types/statuses';
import type { NotificationGap } from 'mastodon/reducers/notification_groups';
import {
  selectSettingsNotificationsExcludedTypes,
  selectSettingsNotificationsQuickFilterActive,
  selectSettingsNotificationsShows,
} from 'mastodon/selectors/settings';
import type { AppDispatch } from 'mastodon/store';
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

export const fetchNotifications = createDataLoadingThunk(
  'notificationGroups/fetch',
  async (_params, { getState }) => {
    const activeFilter =
      selectSettingsNotificationsQuickFilterActive(getState());

    return apiFetchNotifications({
      exclude_types:
        activeFilter === 'all'
          ? selectSettingsNotificationsExcludedTypes(getState())
          : excludeAllTypesExcept(activeFilter),
    });
  },
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
  async (params: { gap: NotificationGap }) =>
    apiFetchNotifications({ max_id: params.gap.maxId }),

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

    return notification;
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
    // dispatch(expandNotifications({ forceLoad: true }));
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
