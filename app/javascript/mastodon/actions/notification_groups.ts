import { createAction } from '@reduxjs/toolkit';

import {
  apiClearNotifications,
  apiFetchNotifications,
} from 'mastodon/api/notifications';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type { ApiGenericJSON } from 'mastodon/api_types/generic';
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
} from 'mastodon/selectors/settings';
import type { AppDispatch } from 'mastodon/store';
import {
  createAppAsyncThunk,
  createDataLoadingThunk,
} from 'mastodon/store/typed_functions';

import { importShallowAccounts } from './accounts_typed';
import {
  importFetchedAccounts,
  importFetchedStatuses,
  importShallowStatuses,
} from './importer';
import { NOTIFICATIONS_FILTER_SET } from './notifications';
import { saveSettings } from './settings';

function excludeAllTypesExcept(filter: string) {
  return allNotificationTypes.filter((item) => item !== filter);
}

function dispatchAssociatedRecords(
  dispatch: AppDispatch,
  notifications: ApiNotificationJSON[],
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

    if ('status' in notification) {
      fetchedStatuses.push(notification.status);
    }
  });

  if (fetchedAccounts.length > 0)
    dispatch(importFetchedAccounts(fetchedAccounts));

  if (fetchedStatuses.length > 0)
    dispatch(importFetchedStatuses(fetchedStatuses));
}

function dispatchGenericAssociatedRecords(
  dispatch: AppDispatch,
  apiResult: ApiGenericJSON,
) {
  if (apiResult.accounts.length > 0)
    dispatch(importShallowAccounts({ accounts: apiResult.accounts }));

  if (apiResult.statuses.length > 0)
    dispatch(importShallowStatuses(apiResult.statuses));
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
  ({ apiResult }, { dispatch }) => {
    dispatchGenericAssociatedRecords(dispatch, apiResult);
    const payload: (ApiNotificationGroupJSON | NotificationGap)[] =
      apiResult.notification_groups;

    // TODO: might be worth not using gaps for that…
    // if (nextLink) payload.push({ type: 'gap', loadUrl: nextLink.uri });
    if (apiResult.notification_groups.length > 1)
      payload.push({
        type: 'gap',
        maxId: apiResult.notification_groups.at(-1)?.page_min_id,
      });

    return payload;
    // dispatch(submitMarkers());
  },
);

export const fetchNotificationsGap = createDataLoadingThunk(
  'notificationGroups/fetchGap',
  async (params: { gap: NotificationGap }) =>
    apiFetchNotifications({ max_id: params.gap.maxId }),

  ({ apiResult }, { dispatch }) => {
    dispatchGenericAssociatedRecords(dispatch, apiResult);

    return { apiResult };
  },
);

export const processNewNotificationForGroups = createAppAsyncThunk(
  'notificationGroups/processNew',
  (notification: ApiNotificationJSON, { dispatch }) => {
    dispatchAssociatedRecords(dispatch, [notification]);

    return notification;
  },
);

export const loadPending = createAction('notificationGroups/loadPending');

export const updateScrollPosition = createAction<{ top: boolean }>(
  'notificationGroups/updateScrollPosition',
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

export const mountNotifications = createAction('notificationGroups/mount');
export const unmountNotifications = createAction('notificationGroups/unmount');
