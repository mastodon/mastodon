import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import {
  blockAccountSuccess,
  muteAccountSuccess,
} from 'mastodon/actions/accounts';
import {
  fetchNotificationRequests,
  expandNotificationRequests,
  fetchNotificationRequest,
  fetchNotificationsForRequest,
  expandNotificationsForRequest,
  acceptNotificationRequest,
  dismissNotificationRequest,
  acceptNotificationRequests,
  dismissNotificationRequests,
} from 'mastodon/actions/notification_requests';
import type { NotificationRequest } from 'mastodon/models/notification_request';
import { createNotificationRequestFromJSON } from 'mastodon/models/notification_request';

import { notificationToMap } from './notifications';

interface NotificationsListState {
  items: unknown[]; // TODO
  isLoading: boolean;
  next: string | null;
}

interface CurrentNotificationRequestState {
  item: NotificationRequest | null;
  isLoading: boolean;
  removed: boolean;
  notifications: NotificationsListState;
}

interface NotificationRequestsState {
  items: NotificationRequest[];
  isLoading: boolean;
  next: string | null;
  current: CurrentNotificationRequestState;
}

const initialState: NotificationRequestsState = {
  items: [],
  isLoading: false,
  next: null,
  current: {
    item: null,
    isLoading: false,
    removed: false,
    notifications: {
      isLoading: false,
      items: [],
      next: null,
    },
  },
};

const removeRequest = (state: NotificationRequestsState, id: string) => {
  if (state.current.item?.id === id) {
    state.current.removed = true;
  }

  state.items = state.items.filter((item) => item.id !== id);
};

const removeRequestByAccount = (
  state: NotificationRequestsState,
  account_id: string,
) => {
  if (state.current.item?.account_id === account_id) {
    state.current.removed = true;
  }

  state.items = state.items.filter((item) => item.account_id !== account_id);
};

export const notificationRequestsReducer =
  createReducer<NotificationRequestsState>(initialState, (builder) => {
    builder
      .addCase(fetchNotificationRequests.fulfilled, (state, action) => {
        state.items = action.payload.requests
          .map(createNotificationRequestFromJSON)
          .concat(state.items);
        state.isLoading = false;
        state.next ??= action.payload.next ?? null;
      })
      .addCase(expandNotificationRequests.fulfilled, (state, action) => {
        state.items = state.items.concat(
          action.payload.requests.map(createNotificationRequestFromJSON),
        );
        state.isLoading = false;
        state.next = action.payload.next ?? null;
      })
      .addCase(blockAccountSuccess, (state, action) => {
        removeRequestByAccount(state, action.payload.relationship.id);
      })
      .addCase(muteAccountSuccess, (state, action) => {
        if (action.payload.relationship.muting_notifications)
          removeRequestByAccount(state, action.payload.relationship.id);
      })
      .addCase(fetchNotificationRequest.pending, (state) => {
        state.current = { ...initialState.current, isLoading: true };
      })
      .addCase(fetchNotificationRequest.rejected, (state) => {
        state.current.isLoading = false;
      })
      .addCase(fetchNotificationRequest.fulfilled, (state, action) => {
        state.current.isLoading = false;
        state.current.item = createNotificationRequestFromJSON(action.payload);
      })
      .addCase(fetchNotificationsForRequest.fulfilled, (state, action) => {
        state.current.notifications.isLoading = false;
        state.current.notifications.items.unshift(
          ...action.payload.notifications.map(notificationToMap),
        );
        state.current.notifications.next ??= action.payload.next ?? null;
      })
      .addCase(expandNotificationsForRequest.fulfilled, (state, action) => {
        state.current.notifications.isLoading = false;
        state.current.notifications.items.push(
          ...action.payload.notifications.map(notificationToMap),
        );
        state.current.notifications.next = action.payload.next ?? null;
      })
      .addMatcher(
        isAnyOf(
          fetchNotificationRequests.pending,
          expandNotificationRequests.pending,
        ),
        (state) => {
          state.isLoading = true;
        },
      )
      .addMatcher(
        isAnyOf(
          fetchNotificationRequests.rejected,
          expandNotificationRequests.rejected,
        ),
        (state) => {
          state.isLoading = false;
        },
      )
      .addMatcher(
        isAnyOf(
          acceptNotificationRequest.pending,
          dismissNotificationRequest.pending,
        ),
        (state, action) => {
          removeRequest(state, action.meta.arg.id);
        },
      )
      .addMatcher(
        isAnyOf(
          acceptNotificationRequests.pending,
          dismissNotificationRequests.pending,
        ),
        (state, action) => {
          action.meta.arg.ids.forEach((id) => {
            removeRequest(state, id);
          });
        },
      )
      .addMatcher(
        isAnyOf(
          fetchNotificationsForRequest.pending,
          expandNotificationsForRequest.pending,
        ),
        (state) => {
          state.current.notifications.isLoading = true;
        },
      )
      .addMatcher(
        isAnyOf(
          fetchNotificationsForRequest.rejected,
          expandNotificationsForRequest.rejected,
        ),
        (state) => {
          state.current.notifications.isLoading = false;
        },
      );
  });
