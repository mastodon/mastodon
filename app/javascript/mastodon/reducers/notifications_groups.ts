import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import {
  fetchNotifications,
  fetchNotificationsGap,
} from 'mastodon/actions/notification_groups';
import { createNotificationGroupFromJSON } from 'mastodon/models/notification_group';
import type { NotificationGroup } from 'mastodon/models/notification_group';

export interface NotificationGap {
  type: 'gap';
  loadUrl: string;
}

interface NotificationGroupsState {
  groups: (NotificationGroup | NotificationGap)[];
  unread: number;
  isLoading: boolean;
  hasMore: boolean;
  readMarkerId: string;
}

const initialState: NotificationGroupsState = {
  groups: [],
  unread: 0,
  isLoading: false,
  hasMore: false,
  readMarkerId: '0',
};

export const notificationGroupsReducer = createReducer<NotificationGroupsState>(
  initialState,
  (builder) => {
    builder
      .addCase(fetchNotifications.fulfilled, (state, action) => {
        state.groups = action.payload.map((json) =>
          json.type === 'gap' ? json : createNotificationGroupFromJSON(json),
        );
        state.isLoading = false;
      })
      .addCase(fetchNotificationsGap.fulfilled, (state, action) => {
        const { notifications, nextLink } = action.payload;

        // find the gap in the existing notifications
        const gapIndex = state.groups.findIndex(
          (groupOrGap) =>
            groupOrGap.type === 'gap' && groupOrGap.loadUrl === nextLink?.uri,
        );

        if (!gapIndex)
          // We do not know where to insert, let's return
          return;

        // replace the gap with the notifications + a new gap

        const toInsert: NotificationGroupsState['groups'] = notifications.map(
          (json) => createNotificationGroupFromJSON(json),
        );

        if (nextLink?.uri && notifications.length > 0) {
          // If we get an empty page, it means we reached the bottom, so we do not need to insert a new gap
          toInsert.push({
            type: 'gap',
            loadUrl: nextLink.uri,
          } as NotificationGap);
        }

        state.groups.splice(gapIndex, 1, ...toInsert);

        state.isLoading = false;
      })
      .addMatcher(
        isAnyOf(fetchNotifications.pending, fetchNotificationsGap.pending),
        (state) => {
          state.isLoading = true;
        },
      )
      .addMatcher(
        isAnyOf(fetchNotifications.rejected, fetchNotificationsGap.rejected),
        (state) => {
          state.isLoading = false;
        },
      );
  },
);
