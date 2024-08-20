import { createAction } from '@reduxjs/toolkit';

import {
  apiGetNotificationPolicy,
  apiUpdateNotificationsPolicy,
} from 'mastodon/api/notification_policies';
import type { NotificationPolicy } from 'mastodon/models/notification_policy';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const fetchNotificationPolicy = createDataLoadingThunk(
  'notificationPolicy/fetch',
  () => apiGetNotificationPolicy(),
);

export const updateNotificationsPolicy = createDataLoadingThunk(
  'notificationPolicy/update',
  (policy: Partial<NotificationPolicy>) => apiUpdateNotificationsPolicy(policy),
);

export const decreasePendingNotificationsCount = createAction<number>(
  'notificationPolicy/decreasePendingNotificationCount',
);
