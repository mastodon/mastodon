import {
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_EXPAND_SUCCESS,
  NOTIFICATIONS_EXPAND_REQUEST,
  NOTIFICATIONS_EXPAND_FAIL,
  NOTIFICATIONS_FILTER_SET,
  NOTIFICATIONS_CLEAR,
  NOTIFICATIONS_SCROLL_TOP,
  NOTIFICATIONS_LOAD_PENDING,
  NOTIFICATIONS_MOUNT,
  NOTIFICATIONS_UNMOUNT,
} from '../actions/notifications';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
  FOLLOW_REQUEST_AUTHORIZE_SUCCESS,
  FOLLOW_REQUEST_REJECT_SUCCESS,
} from '../actions/accounts';
import { DOMAIN_BLOCK_SUCCESS } from 'mastodon/actions/domain_blocks';
import { TIMELINE_DELETE, TIMELINE_DISCONNECT } from '../actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import compareId from '../compare_id';

const initialState = ImmutableMap({
  pendingItems: ImmutableList(),
  items: ImmutableList(),
  hasMore: true,
  top: false,
  mounted: false,
  unread: 0,
  isLoading: false,
});

const notificationToMap = notification => ImmutableMap({
  id: notification.id,
  type: notification.type,
  account: notification.account.id,
  created_at: notification.created_at,
  status: notification.status ? notification.status.id : null,
});

const normalizeNotification = (state, notification, usePendingItems) => {
  const top = state.get('top');

  if (usePendingItems || !state.get('pendingItems').isEmpty()) {
    return state.update('pendingItems', list => list.unshift(notificationToMap(notification))).update('unread', unread => unread + 1);
  }

  if (!top) {
    state = state.update('unread', unread => unread + 1);
  }

  return state.update('items', list => {
    if (top && list.size > 40) {
      list = list.take(20);
    }

    return list.unshift(notificationToMap(notification));
  });
};

const expandNormalizedNotifications = (state, notifications, next, isLoadingRecent, usePendingItems) => {
  let items = ImmutableList();

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(n));
  });

  return state.withMutations(mutable => {
    if (!items.isEmpty()) {
      usePendingItems = isLoadingRecent && (usePendingItems || !mutable.get('pendingItems').isEmpty());

      mutable.update(usePendingItems ? 'pendingItems' : 'items', list => {
        const lastIndex = 1 + list.findLastIndex(
          item => item !== null && (compareId(item.get('id'), items.last().get('id')) > 0 || item.get('id') === items.last().get('id')),
        );

        const firstIndex = 1 + list.take(lastIndex).findLastIndex(
          item => item !== null && compareId(item.get('id'), items.first().get('id')) > 0,
        );

        return list.take(firstIndex).concat(items, list.skip(lastIndex));
      });
    }

    if (!next) {
      mutable.set('hasMore', false);
    }

    mutable.set('isLoading', false);
  });
};

const filterNotifications = (state, accountIds, type) => {
  const helper = list => list.filterNot(item => item !== null && accountIds.includes(item.get('account')) && (type === undefined || type === item.get('type')));
  return state.update('items', helper).update('pendingItems', helper);
};

const updateTop = (state, top) => {
  if (top) {
    state = state.set('unread', state.get('pendingItems').size);
  }

  return state.set('top', top);
};

const deleteByStatus = (state, statusId) => {
  const helper = list => list.filterNot(item => item !== null && item.get('status') === statusId);
  return state.update('items', helper).update('pendingItems', helper);
};

export default function notifications(state = initialState, action) {
  switch(action.type) {
  case NOTIFICATIONS_LOAD_PENDING:
    return state.update('items', list => state.get('pendingItems').concat(list.take(40))).set('pendingItems', ImmutableList()).set('unread', 0);
  case NOTIFICATIONS_EXPAND_REQUEST:
    return state.set('isLoading', true);
  case NOTIFICATIONS_EXPAND_FAIL:
    return state.set('isLoading', false);
  case NOTIFICATIONS_FILTER_SET:
    return state.set('items', ImmutableList()).set('pendingItems', ImmutableList()).set('hasMore', true);
  case NOTIFICATIONS_SCROLL_TOP:
    return updateTop(state, action.top);
  case NOTIFICATIONS_UPDATE:
    return normalizeNotification(state, action.notification, action.usePendingItems);
  case NOTIFICATIONS_EXPAND_SUCCESS:
    return expandNormalizedNotifications(state, action.notifications, action.next, action.isLoadingRecent, action.usePendingItems);
  case ACCOUNT_BLOCK_SUCCESS:
    return filterNotifications(state, [action.relationship.id]);
  case ACCOUNT_MUTE_SUCCESS:
    return action.relationship.muting_notifications ? filterNotifications(state, [action.relationship.id]) : state;
  case DOMAIN_BLOCK_SUCCESS:
    return filterNotifications(state, action.accounts);
  case FOLLOW_REQUEST_AUTHORIZE_SUCCESS:
  case FOLLOW_REQUEST_REJECT_SUCCESS:
    return filterNotifications(state, [action.id], 'follow_request');
  case ACCOUNT_MUTE_SUCCESS:
    return action.relationship.muting_notifications ? filterNotifications(state, [action.relationship.id]) : state;
  case NOTIFICATIONS_CLEAR:
    return state.set('items', ImmutableList()).set('pendingItems', ImmutableList()).set('hasMore', false);
  case TIMELINE_DELETE:
    return deleteByStatus(state, action.id);
  case TIMELINE_DISCONNECT:
    return action.timeline === 'home' ?
      state.update(action.usePendingItems ? 'pendingItems' : 'items', items => items.first() ? items.unshift(null) : items) :
      state;
  case NOTIFICATIONS_MOUNT:
    return state.set('mounted', true);
  case NOTIFICATIONS_UNMOUNT:
    return state.set('mounted', false);
  default:
    return state;
  }
};
