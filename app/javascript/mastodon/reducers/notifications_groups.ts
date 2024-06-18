import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import {
  authorizeFollowRequestSuccess,
  blockAccountSuccess,
  muteAccountSuccess,
  rejectFollowRequestSuccess,
} from 'mastodon/actions/accounts_typed';
import { blockDomainSuccess } from 'mastodon/actions/domain_blocks_typed';
import {
  clearNotifications,
  fetchNotifications,
  fetchNotificationsGap,
  processNewNotificationForGroups,
} from 'mastodon/actions/notification_groups';
import {
  disconnectTimeline,
  timelineDelete,
} from 'mastodon/actions/timelines_typed';
import {
  NOTIFICATIONS_GROUP_MAX_AVATARS,
  createNotificationGroupFromJSON,
  createNotificationGroupFromNotificationJSON,
} from 'mastodon/models/notification_group';
import type { NotificationGroup } from 'mastodon/models/notification_group';

export interface NotificationGap {
  type: 'gap';
  loadUrl: string;
}

interface NotificationGroupsState {
  groups: (NotificationGroup | NotificationGap)[];
  isLoading: boolean;
  hasMore: boolean;
}

const initialState: NotificationGroupsState = {
  groups: [],
  isLoading: false,
  hasMore: false,
};

function removeNotificationsForAccounts(
  state: NotificationGroupsState,
  accountIds: string[],
  onlyForType?: string,
) {
  state.groups = state.groups
    .map((group) => {
      if (
        group.type !== 'gap' &&
        (!onlyForType || group.type === onlyForType)
      ) {
        const previousLength = group.sampleAccountsIds.length;

        group.sampleAccountsIds = group.sampleAccountsIds.filter(
          (id) => !accountIds.includes(id),
        );

        const newLength = group.sampleAccountsIds.length;
        const removed = previousLength - newLength;

        group.notifications_count -= removed;
      }

      return group;
    })
    .filter(
      (group) => group.type === 'gap' || group.sampleAccountsIds.length > 0,
    );
}

function removeNotificationsForStatus(
  state: NotificationGroupsState,
  statusId: string,
) {
  state.groups = state.groups.filter(
    (group) =>
      group.type === 'gap' ||
      !('statusId' in group) ||
      group.statusId !== statusId,
  );
}

export const notificationsGroupsReducer =
  createReducer<NotificationGroupsState>(initialState, (builder) => {
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
      .addCase(processNewNotificationForGroups.fulfilled, (state, action) => {
        const notification = action.payload;
        const existingGroupIndex = state.groups.findIndex(
          (group) =>
            group.type !== 'gap' && group.group_key === notification.group_key,
        );

        if (existingGroupIndex > -1) {
          const existingGroup = state.groups[existingGroupIndex];

          if (existingGroup && existingGroup.type !== 'gap') {
            // Update the existing group
            if (
              existingGroup.sampleAccountsIds.unshift(notification.account.id) >
              NOTIFICATIONS_GROUP_MAX_AVATARS
            )
              existingGroup.sampleAccountsIds.pop();

            existingGroup.most_recent_notification_id = notification.id;
            existingGroup.page_max_id = notification.id;
            existingGroup.latest_page_notification_at = notification.created_at;
            existingGroup.notifications_count += 1;

            state.groups.splice(existingGroupIndex, 1);
            state.groups.unshift(existingGroup);
          }
        } else {
          // Create a new group
          state.groups.unshift(
            createNotificationGroupFromNotificationJSON(notification),
          );
        }
      })
      .addCase(disconnectTimeline, (state, action) => {
        if (action.payload.timeline === 'home')
          state.groups.unshift({
            type: 'gap',
            loadUrl: 'TODO_LOAD_URL_TOP_OF_TL', // TODO
          });
      })
      .addCase(timelineDelete, (state, action) => {
        removeNotificationsForStatus(state, action.payload.statusId);
      })
      .addCase(clearNotifications.pending, (state) => {
        state.groups = [];
        state.hasMore = false;
      })
      .addCase(blockAccountSuccess, (state, action) => {
        removeNotificationsForAccounts(state, [action.payload.relationship.id]);
      })
      .addCase(muteAccountSuccess, (state, action) => {
        if (action.payload.relationship.muting_notifications)
          removeNotificationsForAccounts(state, [
            action.payload.relationship.id,
          ]);
      })
      .addCase(blockDomainSuccess, (state, action) => {
        removeNotificationsForAccounts(
          state,
          action.payload.accounts.map((account) => account.id),
        );
      })
      .addMatcher(
        isAnyOf(authorizeFollowRequestSuccess, rejectFollowRequestSuccess),
        (state, action) => {
          removeNotificationsForAccounts(
            state,
            [action.payload.id],
            'follow_request',
          );
        },
      )
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
  });
