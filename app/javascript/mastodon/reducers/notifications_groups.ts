import { createReducer } from '@reduxjs/toolkit';

import { fetchNotifications } from 'mastodon/actions/notification_groups';
import { createNotificationGroupFromJSON } from 'mastodon/models/notification_group';
import type { NotificationGroup } from 'mastodon/models/notification_group';

interface NotificationGroupsState {
  groups: NotificationGroup[];
  unread: number;
}

const initialState: NotificationGroupsState = {
  groups: [],
  unread: 0,
};

export const notificationGroupsReducer = createReducer(
  initialState,
  (builder) => {
    builder.addCase(fetchNotifications.fulfilled, (state, action) => {
      state.groups = action.payload.map((json) =>
        createNotificationGroupFromJSON(json),
      );
    });
  },
);
