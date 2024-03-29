import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import {
  fetchNotificationPolicy,
  updateNotificationsPolicy,
} from 'mastodon/actions/notification_policies';
import type { NotificationPolicy } from 'mastodon/models/notification_policy';

export const notificationPolicyReducer =
  createReducer<NotificationPolicy | null>(null, (builder) => {
    builder.addMatcher(
      isAnyOf(
        fetchNotificationPolicy.fulfilled,
        updateNotificationsPolicy.fulfilled,
      ),
      (_state, action) => action.payload,
    );
  });
