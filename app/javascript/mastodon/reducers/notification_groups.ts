import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import {
  authorizeFollowRequestSuccess,
  blockAccountSuccess,
  muteAccountSuccess,
  rejectFollowRequestSuccess,
} from 'mastodon/actions/accounts_typed';
import { focusApp, unfocusApp } from 'mastodon/actions/app';
import { blockDomainSuccess } from 'mastodon/actions/domain_blocks_typed';
import { fetchMarkers } from 'mastodon/actions/markers';
import {
  clearNotifications,
  fetchNotifications,
  fetchNotificationsGap,
  processNewNotificationForGroups,
  loadPending,
  updateScrollPosition,
  markNotificationsAsRead,
  mountNotifications,
  unmountNotifications,
  refreshStaleNotificationGroups,
  pollRecentNotifications,
} from 'mastodon/actions/notification_groups';
import {
  disconnectTimeline,
  timelineDelete,
} from 'mastodon/actions/timelines_typed';
import type {
  ApiNotificationJSON,
  ApiNotificationGroupJSON,
  NotificationType,
} from 'mastodon/api_types/notifications';
import { compareId } from 'mastodon/compare_id';
import { usePendingItems } from 'mastodon/initial_state';
import {
  NOTIFICATIONS_GROUP_MAX_AVATARS,
  createNotificationGroupFromJSON,
  createNotificationGroupFromNotificationJSON,
} from 'mastodon/models/notification_group';
import type { NotificationGroup } from 'mastodon/models/notification_group';

const NOTIFICATIONS_TRIM_LIMIT = 50;

export interface NotificationGap {
  type: 'gap';
  maxId?: string;
  sinceId?: string;
}

interface NotificationGroupsState {
  groups: (NotificationGroup | NotificationGap)[];
  pendingGroups: (NotificationGroup | NotificationGap)[];
  scrolledToTop: boolean;
  isLoading: boolean;
  lastReadId: string;
  readMarkerId: string;
  mounted: number;
  isTabVisible: boolean;
  mergedNotifications: 'ok' | 'pending' | 'needs-reload';
}

const initialState: NotificationGroupsState = {
  groups: [],
  pendingGroups: [], // holds pending groups in slow mode
  scrolledToTop: false,
  isLoading: false,
  // this is used to track whether we need to refresh notifications after accepting requests
  mergedNotifications: 'ok',
  // The following properties are used to track unread notifications
  lastReadId: '0', // used internally for unread notifications
  readMarkerId: '0', // user-facing and updated when focus changes
  mounted: 0, // number of mounted notification list components, usually 0 or 1
  isTabVisible: true,
};

function filterNotificationsForAccounts(
  groups: NotificationGroupsState['groups'],
  accountIds: string[],
  onlyForType?: string,
) {
  groups = groups
    .map((group) => {
      if (
        group.type !== 'gap' &&
        (!onlyForType || group.type === onlyForType)
      ) {
        const previousLength = group.sampleAccountIds.length;

        group.sampleAccountIds = group.sampleAccountIds.filter(
          (id) => !accountIds.includes(id),
        );

        const newLength = group.sampleAccountIds.length;
        const removed = previousLength - newLength;

        group.notifications_count -= removed;
      }

      return group;
    })
    .filter(
      (group) => group.type === 'gap' || group.sampleAccountIds.length > 0,
    );
  mergeGaps(groups);
  return groups;
}

function filterNotificationsForStatus(
  groups: NotificationGroupsState['groups'],
  statusId: string,
) {
  groups = groups.filter(
    (group) =>
      group.type === 'gap' ||
      !('statusId' in group) ||
      group.statusId !== statusId,
  );
  mergeGaps(groups);
  return groups;
}

function removeNotificationsForAccounts(
  state: NotificationGroupsState,
  accountIds: string[],
  onlyForType?: string,
) {
  state.groups = filterNotificationsForAccounts(
    state.groups,
    accountIds,
    onlyForType,
  );
  state.pendingGroups = filterNotificationsForAccounts(
    state.pendingGroups,
    accountIds,
    onlyForType,
  );
}

function removeNotificationsForStatus(
  state: NotificationGroupsState,
  statusId: string,
) {
  state.groups = filterNotificationsForStatus(state.groups, statusId);
  state.pendingGroups = filterNotificationsForStatus(
    state.pendingGroups,
    statusId,
  );
}

function isNotificationGroup(
  groupOrGap: NotificationGroup | NotificationGap,
): groupOrGap is NotificationGroup {
  return groupOrGap.type !== 'gap';
}

// Merge adjacent gaps in `groups` in-place
function mergeGaps(groups: NotificationGroupsState['groups']) {
  for (let i = 0; i < groups.length; i++) {
    const firstGroupOrGap = groups[i];

    if (firstGroupOrGap?.type === 'gap') {
      let lastGap = firstGroupOrGap;
      let j = i + 1;

      for (; j < groups.length; j++) {
        const groupOrGap = groups[j];
        if (groupOrGap?.type === 'gap') lastGap = groupOrGap;
        else break;
      }

      if (j - i > 1) {
        groups.splice(i, j - i, {
          type: 'gap',
          maxId: firstGroupOrGap.maxId,
          sinceId: lastGap.sinceId,
        });
      }
    }
  }
}

// Checks if `groups[index-1]` and `groups[index]` are gaps, and merge them in-place if they are
function mergeGapsAround(
  groups: NotificationGroupsState['groups'],
  index: number,
) {
  if (index > 0) {
    const potentialFirstGap = groups[index - 1];
    const potentialSecondGap = groups[index];

    if (
      potentialFirstGap?.type === 'gap' &&
      potentialSecondGap?.type === 'gap'
    ) {
      groups.splice(index - 1, 2, {
        type: 'gap',
        maxId: potentialFirstGap.maxId,
        sinceId: potentialSecondGap.sinceId,
      });
    }
  }
}

function processNewNotification(
  groups: NotificationGroupsState['groups'],
  notification: ApiNotificationJSON,
  groupedTypes: NotificationType[],
) {
  if (!groupedTypes.includes(notification.type)) {
    notification = {
      ...notification,
      group_key: `ungrouped-${notification.id}`,
    };
  }

  const existingGroupIndex = groups.findIndex(
    (group) =>
      group.type !== 'gap' && group.group_key === notification.group_key,
  );

  // In any case, we are going to add a group at the top
  // If there is currently a gap at the top, now is the time to update it
  if (groups.length > 0 && groups[0]?.type === 'gap') {
    groups[0].maxId = notification.id;
  }

  if (existingGroupIndex > -1) {
    const existingGroup = groups[existingGroupIndex];

    if (
      existingGroup &&
      existingGroup.type !== 'gap' &&
      !existingGroup.sampleAccountIds.includes(notification.account.id) // This can happen for example if you like, then unlike, then like again the same post
    ) {
      // Update the existing group
      if (
        existingGroup.sampleAccountIds.unshift(notification.account.id) >
        NOTIFICATIONS_GROUP_MAX_AVATARS
      )
        existingGroup.sampleAccountIds.pop();

      existingGroup.most_recent_notification_id = notification.id;
      existingGroup.page_max_id = notification.id;
      existingGroup.latest_page_notification_at = notification.created_at;
      existingGroup.notifications_count += 1;

      groups.splice(existingGroupIndex, 1);
      mergeGapsAround(groups, existingGroupIndex);

      groups.unshift(existingGroup);
    }
  } else {
    // We have not found an existing group, create a new one
    groups.unshift(createNotificationGroupFromNotificationJSON(notification));
  }
}

function trimNotifications(state: NotificationGroupsState) {
  if (state.scrolledToTop && state.groups.length > NOTIFICATIONS_TRIM_LIMIT) {
    state.groups.splice(NOTIFICATIONS_TRIM_LIMIT);
    ensureTrailingGap(state.groups);
  }
}

function shouldMarkNewNotificationsAsRead(
  {
    isTabVisible,
    scrolledToTop,
    mounted,
    lastReadId,
    groups,
  }: NotificationGroupsState,
  ignoreScroll = false,
) {
  const isMounted = mounted > 0;
  const oldestGroup = groups.findLast(isNotificationGroup);
  const hasMore = groups.at(-1)?.type === 'gap';
  const oldestGroupReached =
    !hasMore ||
    lastReadId === '0' ||
    (oldestGroup?.page_min_id &&
      compareId(oldestGroup.page_min_id, lastReadId) <= 0);

  return (
    isTabVisible &&
    (ignoreScroll || scrolledToTop) &&
    isMounted &&
    oldestGroupReached
  );
}

function updateLastReadId(
  state: NotificationGroupsState,
  group: NotificationGroup | undefined = undefined,
) {
  if (shouldMarkNewNotificationsAsRead(state)) {
    group = group ?? state.groups.find(isNotificationGroup);
    if (
      group?.page_max_id &&
      compareId(state.lastReadId, group.page_max_id) < 0
    )
      state.lastReadId = group.page_max_id;
  }
}

function commitLastReadId(state: NotificationGroupsState) {
  if (shouldMarkNewNotificationsAsRead(state)) {
    state.readMarkerId = state.lastReadId;
  }
}

function fillNotificationsGap(
  groups: NotificationGroupsState['groups'],
  gap: NotificationGap,
  notifications: ApiNotificationGroupJSON[],
): NotificationGroupsState['groups'] {
  // find the gap in the existing notifications
  const gapIndex = groups.findIndex(
    (groupOrGap) =>
      groupOrGap.type === 'gap' &&
      groupOrGap.sinceId === gap.sinceId &&
      groupOrGap.maxId === gap.maxId,
  );

  if (gapIndex < 0)
    // We do not know where to insert, let's return
    return groups;

  // Filling a disconnection gap means we're getting historical data
  // about groups we may know or may not know about.

  // The notifications timeline is split in two by the gap, with
  // group information newer than the gap, and group information older
  // than the gap.

  // Filling a gap should not touch anything before the gap, so any
  // information on groups already appearing before the gap should be
  // discarded, while any information on groups appearing after the gap
  // can be updated and re-ordered.

  const oldestPageNotification = notifications.at(-1)?.page_min_id;

  // replace the gap with the notifications + a new gap

  const newerGroupKeys = groups
    .slice(0, gapIndex)
    .filter(isNotificationGroup)
    .map((group) => group.group_key);

  const toInsert: NotificationGroupsState['groups'] = notifications
    .map((json) => createNotificationGroupFromJSON(json))
    .filter((notification) => !newerGroupKeys.includes(notification.group_key));

  const apiGroupKeys = (toInsert as NotificationGroup[]).map(
    (group) => group.group_key,
  );

  const sinceId = gap.sinceId;
  if (
    notifications.length > 0 &&
    !(
      oldestPageNotification &&
      sinceId &&
      compareId(oldestPageNotification, sinceId) <= 0
    )
  ) {
    // If we get an empty page, it means we reached the bottom, so we do not need to insert a new gap
    // Similarly, if we've fetched more than the gap's, this means we have completely filled it
    toInsert.push({
      type: 'gap',
      maxId: notifications.at(-1)?.page_max_id,
      sinceId,
    } as NotificationGap);
  }

  // Remove older groups covered by the API
  groups = groups.filter(
    (groupOrGap) =>
      groupOrGap.type !== 'gap' && !apiGroupKeys.includes(groupOrGap.group_key),
  );

  // Replace the gap with API results (+ the new gap if needed)
  groups.splice(gapIndex, 1, ...toInsert);

  // Finally, merge any adjacent gaps that could have been created by filtering
  // groups earlier
  mergeGaps(groups);

  return groups;
}

// Ensure the groups list starts with a gap, mutating it to prepend one if needed
function ensureLeadingGap(
  groups: NotificationGroupsState['groups'],
): NotificationGap {
  if (groups[0]?.type === 'gap') {
    // We're expecting new notifications, so discard the maxId if there is one
    groups[0].maxId = undefined;

    return groups[0];
  } else {
    const gap: NotificationGap = {
      type: 'gap',
      sinceId: groups[0]?.page_min_id,
    };

    groups.unshift(gap);
    return gap;
  }
}

// Ensure the groups list ends with a gap suitable for loading more, mutating it to append one if needed
function ensureTrailingGap(
  groups: NotificationGroupsState['groups'],
): NotificationGap {
  const groupOrGap = groups.at(-1);

  if (groupOrGap?.type === 'gap') {
    // We're expecting older notifications, so discard sinceId if it's set
    groupOrGap.sinceId = undefined;

    return groupOrGap;
  } else {
    const gap: NotificationGap = {
      type: 'gap',
      maxId: groupOrGap?.page_min_id,
    };

    groups.push(gap);
    return gap;
  }
}

export const notificationGroupsReducer = createReducer<NotificationGroupsState>(
  initialState,
  (builder) => {
    builder
      .addCase(fetchNotifications.fulfilled, (state, action) => {
        state.groups = action.payload.map((json) =>
          json.type === 'gap' ? json : createNotificationGroupFromJSON(json),
        );
        state.isLoading = false;
        state.mergedNotifications = 'ok';
        updateLastReadId(state);
      })
      .addCase(fetchNotificationsGap.fulfilled, (state, action) => {
        state.groups = fillNotificationsGap(
          state.groups,
          action.meta.arg.gap,
          action.payload.notifications,
        );
        state.isLoading = false;

        updateLastReadId(state);
      })
      .addCase(pollRecentNotifications.fulfilled, (state, action) => {
        if (usePendingItems) {
          const gap = ensureLeadingGap(state.pendingGroups);
          state.pendingGroups = fillNotificationsGap(
            state.pendingGroups,
            gap,
            action.payload.notifications,
          );
        } else {
          const gap = ensureLeadingGap(state.groups);
          state.groups = fillNotificationsGap(
            state.groups,
            gap,
            action.payload.notifications,
          );
        }

        state.isLoading = false;

        updateLastReadId(state);
        trimNotifications(state);
      })
      .addCase(processNewNotificationForGroups.fulfilled, (state, action) => {
        if (action.payload) {
          const { notification, groupedTypes } = action.payload;

          processNewNotification(
            usePendingItems ? state.pendingGroups : state.groups,
            notification,
            groupedTypes,
          );
          updateLastReadId(state);
          trimNotifications(state);
        }
      })
      .addCase(disconnectTimeline, (state, action) => {
        if (action.payload.timeline === 'home') {
          const groups = usePendingItems ? state.pendingGroups : state.groups;
          if (groups.length > 0 && groups[0]?.type !== 'gap') {
            groups.unshift({
              type: 'gap',
              sinceId: groups[0]?.page_min_id,
            });
          }
        }
      })
      .addCase(timelineDelete, (state, action) => {
        removeNotificationsForStatus(state, action.payload.statusId);
      })
      .addCase(clearNotifications.pending, (state) => {
        state.groups = [];
        state.pendingGroups = [];
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
      .addCase(loadPending, (state) => {
        // First, remove any existing group and merge data
        state.pendingGroups.forEach((group) => {
          if (group.type !== 'gap') {
            const existingGroupIndex = state.groups.findIndex(
              (groupOrGap) =>
                isNotificationGroup(groupOrGap) &&
                groupOrGap.group_key === group.group_key,
            );
            if (existingGroupIndex > -1) {
              const existingGroup = state.groups[existingGroupIndex];
              if (existingGroup && existingGroup.type !== 'gap') {
                if (group.partial) {
                  group.notifications_count +=
                    existingGroup.notifications_count;
                  group.sampleAccountIds = group.sampleAccountIds
                    .concat(existingGroup.sampleAccountIds)
                    .slice(0, NOTIFICATIONS_GROUP_MAX_AVATARS);
                }
                state.groups.splice(existingGroupIndex, 1);
              }
            }
          }
        });

        // Then build the consolidated list and clear pending groups
        state.groups = state.pendingGroups.concat(state.groups);
        state.pendingGroups = [];
        mergeGaps(state.groups);
        trimNotifications(state);
      })
      .addCase(updateScrollPosition.fulfilled, (state, action) => {
        state.scrolledToTop = action.payload.top;
        updateLastReadId(state);
        trimNotifications(state);
      })
      .addCase(markNotificationsAsRead, (state) => {
        const mostRecentGroup = state.groups.find(isNotificationGroup);
        if (
          mostRecentGroup?.page_max_id &&
          compareId(state.lastReadId, mostRecentGroup.page_max_id) < 0
        )
          state.lastReadId = mostRecentGroup.page_max_id;

        // We don't call `commitLastReadId`, because that is conditional
        // and we want to unconditionally update the state instead.
        state.readMarkerId = state.lastReadId;
      })
      .addCase(fetchMarkers.fulfilled, (state, action) => {
        if (
          action.payload.markers.notifications &&
          compareId(
            state.lastReadId,
            action.payload.markers.notifications.last_read_id,
          ) < 0
        ) {
          state.lastReadId = action.payload.markers.notifications.last_read_id;
          state.readMarkerId =
            action.payload.markers.notifications.last_read_id;
        }
      })
      .addCase(mountNotifications.fulfilled, (state) => {
        state.mounted += 1;
        commitLastReadId(state);
        updateLastReadId(state);
      })
      .addCase(unmountNotifications, (state) => {
        state.mounted -= 1;
      })
      .addCase(focusApp, (state) => {
        state.isTabVisible = true;
        commitLastReadId(state);
        updateLastReadId(state);
      })
      .addCase(unfocusApp, (state) => {
        state.isTabVisible = false;
      })
      .addCase(refreshStaleNotificationGroups.fulfilled, (state, action) => {
        if (action.payload.deferredRefresh)
          state.mergedNotifications = 'needs-reload';
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
        isAnyOf(
          fetchNotifications.pending,
          fetchNotificationsGap.pending,
          pollRecentNotifications.pending,
        ),
        (state) => {
          state.isLoading = true;
        },
      )
      .addMatcher(
        isAnyOf(
          fetchNotifications.rejected,
          fetchNotificationsGap.rejected,
          pollRecentNotifications.rejected,
        ),
        (state) => {
          state.isLoading = false;
        },
      );
  },
);
