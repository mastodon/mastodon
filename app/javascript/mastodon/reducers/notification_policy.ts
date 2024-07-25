import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import {
  fetchNotificationPolicy,
  decreasePendingNotificationsCount,
  updateNotificationsPolicy,
} from 'mastodon/actions/notification_policies';
import type { NotificationPolicy } from 'mastodon/models/notification_policy';

export const notificationPolicyReducer =
  createReducer<NotificationPolicy | null>(null, (builder) => {
    builder
      .addCase(decreasePendingNotificationsCount, (state, action) => {
        if (state) {
          state.summary.pending_notifications_count -= action.payload;
          state.summary.pending_requests_count -= 1;
        }
      })
      .addMatcher(
        isAnyOf(
          fetchNotificationPolicy.fulfilled,
          updateNotificationsPolicy.fulfilled,
        ),
        (_state, action) => action.payload,
      );
  });
