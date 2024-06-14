import { apiFetchNotifications } from 'mastodon/api/notifications';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type {
  NotificationGroupJSON,
  NotificationJSON,
} from 'mastodon/api_types/notifications';
import { allNotificationTypes } from 'mastodon/api_types/notifications';
import type { ApiStatusJSON } from 'mastodon/api_types/statuses';
import type { NotificationGap } from 'mastodon/reducers/notifications_groups';
import {
  selectSettingsNotificationsExcludedTypes,
  selectSettingsNotificationsQuickFilterActive,
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
  notifications: NotificationGroupJSON[] | NotificationJSON[],
) {
  const fetchedAccounts: ApiAccountJSON[] = [];
  const fetchedStatuses: ApiStatusJSON[] = [];

  notifications.forEach((notification) => {
    if ('sample_accounts' in notification) {
      fetchedAccounts.push(...notification.sample_accounts);
    }

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
  ({ notifications, links }, { dispatch }) => {
    dispatchAssociatedRecords(dispatch, notifications);

    // We ignore the previous link, as it will always be here but we know there are no more
    // recent notifications when doing the initial load
    const nextLink = links.refs.find((link) => link.rel === 'next');

    const payload: (NotificationGroupJSON | NotificationGap)[] = notifications;

    if (nextLink) payload.push({ type: 'gap', loadUrl: nextLink.uri });

    return payload;
    // dispatch(submitMarkers());
  },
);

export const fetchNotificationsGap = createDataLoadingThunk(
  'notificationGroups/fetchGat',
  async (params: { gap: NotificationGap }) =>
    apiFetchNotifications({}, params.gap.loadUrl),

  ({ notifications, links }, { dispatch }) => {
    dispatchAssociatedRecords(dispatch, notifications);

    const nextLink = links.refs.find((link) => link.rel === 'next');

    return { notifications, nextLink };
  },
);

export const processNewNotificationForGroups = createAppAsyncThunk(
  'notificationsGroups/processNew',
  (notification: NotificationJSON, { dispatch }) => {
    dispatchAssociatedRecords(dispatch, [notification]);

    return notification;
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
