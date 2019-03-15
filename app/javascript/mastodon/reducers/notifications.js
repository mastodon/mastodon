import {
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_EXPAND_SUCCESS,
  NOTIFICATIONS_EXPAND_REQUEST,
  NOTIFICATIONS_EXPAND_FAIL,
  NOTIFICATIONS_FILTER_SET,
  NOTIFICATIONS_CLEAR,
  NOTIFICATIONS_SCROLL_TOP,
} from '../actions/notifications';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
} from '../actions/accounts';
import { TIMELINE_DELETE, TIMELINE_DISCONNECT } from '../actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import compareId from '../compare_id';

const initialState = ImmutableMap({
  items: ImmutableList(),
  hasMore: true,
  top: true,
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

const normalizeNotification = (state, notification) => {
  const top = state.get('top');

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

const expandNormalizedNotifications = (state, notifications, next) => {
  let items = ImmutableList();

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(n));
  });

  return state.withMutations(mutable => {
    if (!items.isEmpty()) {
      mutable.update('items', list => {
        const lastIndex = 1 + list.findLastIndex(
          item => item !== null && (compareId(item.get('id'), items.last().get('id')) > 0 || item.get('id') === items.last().get('id'))
        );

        const firstIndex = 1 + list.take(lastIndex).findLastIndex(
          item => item !== null && compareId(item.get('id'), items.first().get('id')) > 0
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

const filterNotifications = (state, relationship) => {
  return state.update('items', list => list.filterNot(item => item !== null && item.get('account') === relationship.id));
};

const updateTop = (state, top) => {
  if (top) {
    state = state.set('unread', 0);
  }

  return state.set('top', top);
};

const deleteByStatus = (state, statusId) => {
  return state.update('items', list => list.filterNot(item => item !== null && item.get('status') === statusId));
};

export default function notifications(state = initialState, action) {
  switch(action.type) {
  case NOTIFICATIONS_EXPAND_REQUEST:
    return state.set('isLoading', true);
  case NOTIFICATIONS_EXPAND_FAIL:
    return state.set('isLoading', false);
  case NOTIFICATIONS_FILTER_SET:
    return state.set('items', ImmutableList()).set('hasMore', true);
  case NOTIFICATIONS_SCROLL_TOP:
    return updateTop(state, action.top);
  case NOTIFICATIONS_UPDATE:
    return normalizeNotification(state, action.notification);
  case NOTIFICATIONS_EXPAND_SUCCESS:
    return expandNormalizedNotifications(state, action.notifications, action.next);
  case ACCOUNT_BLOCK_SUCCESS:
    return filterNotifications(state, action.relationship);
  case ACCOUNT_MUTE_SUCCESS:
    return action.relationship.muting_notifications ? filterNotifications(state, action.relationship) : state;
  case NOTIFICATIONS_CLEAR:
    return state.set('items', ImmutableList()).set('hasMore', false);
  case TIMELINE_DELETE:
    return deleteByStatus(state, action.id);
  case TIMELINE_DISCONNECT:
    return action.timeline === 'home' ?
      state.update('items', items => items.first() ? items.unshift(null) : items) :
      state;
  default:
    return state;
  }
};
