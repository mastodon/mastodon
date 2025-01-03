import { fromJS, Map as ImmutableMap, List as ImmutableList } from 'immutable';

import { blockDomainSuccess } from 'mastodon/actions/domain_blocks';
import { timelineDelete } from 'mastodon/actions/timelines_typed';

import {
  authorizeFollowRequestSuccess,
  blockAccountSuccess,
  muteAccountSuccess,
  rejectFollowRequestSuccess,
} from '../actions/accounts';
import { clearNotifications } from '../actions/notification_groups';
import {
  notificationsUpdate,
  NOTIFICATIONS_FILTER_SET,
  NOTIFICATIONS_SET_BROWSER_SUPPORT,
  NOTIFICATIONS_SET_BROWSER_PERMISSION,
} from '../actions/notifications';
import { disconnectTimeline } from '../actions/timelines';

const initialState = ImmutableMap({
  pendingItems: ImmutableList(),
  items: ImmutableList(),
  isLoading: 0,
  browserSupport: false,
  browserPermission: 'default',
});

export const notificationToMap = notification => ImmutableMap({
  id: notification.id,
  type: notification.type,
  account: notification.account.id,
  created_at: notification.created_at,
  status: notification.status ? notification.status.id : null,
  report: notification.report ? fromJS(notification.report) : null,
  event: notification.event ? fromJS(notification.event) : null,
  moderation_warning: notification.moderation_warning ? fromJS(notification.moderation_warning) : null,
});

const normalizeNotification = (state, notification, usePendingItems) => {
  // Under currently unknown conditions, the client may receive duplicates from the server
  if (state.get('pendingItems').some((item) => item?.get('id') === notification.id) || state.get('items').some((item) => item?.get('id') === notification.id)) {
    return state;
  }

  if (usePendingItems || !state.get('pendingItems').isEmpty()) {
    return state.update('pendingItems', list => list.unshift(notificationToMap(notification)));
  }

  return state.update('items', list => {
    if (list.size > 40) {
      list = list.take(20);
    }

    return list.unshift(notificationToMap(notification));
  });
};

const filterNotifications = (state, accountIds, type) => {
  const helper = list => list.filterNot(item => item !== null && accountIds.includes(item.get('account')) && (type === undefined || type === item.get('type')));
  return state.update('items', helper).update('pendingItems', helper);
};

const deleteByStatus = (state, statusId) => {
  const helper = list => list.filterNot(item => item !== null && item.get('status') === statusId);
  return state.update('items', helper).update('pendingItems', helper);
};

export default function notifications(state = initialState, action) {
  switch(action.type) {
  case NOTIFICATIONS_FILTER_SET:
    return state.set('items', ImmutableList()).set('pendingItems', ImmutableList());
  case notificationsUpdate.type:
    return normalizeNotification(state, action.payload.notification, action.payload.usePendingItems);
  case blockAccountSuccess.type:
    return filterNotifications(state, [action.payload.relationship.id]);
  case muteAccountSuccess.type:
    return action.payload.relationship.muting_notifications ? filterNotifications(state, [action.payload.relationship.id]) : state;
  case blockDomainSuccess.type:
    return filterNotifications(state, action.payload.accounts);
  case authorizeFollowRequestSuccess.type:
  case rejectFollowRequestSuccess.type:
    return filterNotifications(state, [action.payload.id], 'follow_request');
  case clearNotifications.pending.type:
    return state.set('items', ImmutableList()).set('pendingItems', ImmutableList());
  case timelineDelete.type:
    return deleteByStatus(state, action.payload.statusId);
  case disconnectTimeline.type:
    return action.payload.timeline === 'home' ?
      state.update(action.payload.usePendingItems ? 'pendingItems' : 'items', items => items.first() ? items.unshift(null) : items) :
      state;
  case NOTIFICATIONS_SET_BROWSER_SUPPORT:
    return state.set('browserSupport', action.value);
  case NOTIFICATIONS_SET_BROWSER_PERMISSION:
    return state.set('browserPermission', action.value);
  default:
    return state;
  }
}
