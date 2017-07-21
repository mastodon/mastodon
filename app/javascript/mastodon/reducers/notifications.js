import {
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_REFRESH_SUCCESS,
  NOTIFICATIONS_EXPAND_SUCCESS,
  NOTIFICATIONS_REFRESH_REQUEST,
  NOTIFICATIONS_EXPAND_REQUEST,
  NOTIFICATIONS_REFRESH_FAIL,
  NOTIFICATIONS_EXPAND_FAIL,
  NOTIFICATIONS_CLEAR,
  NOTIFICATIONS_SCROLL_TOP,
  NOTIFICATIONS_DELETE_MARKED_REQUEST,
  NOTIFICATIONS_DELETE_MARKED_SUCCESS,
  NOTIFICATION_MARK_FOR_DELETE,
  NOTIFICATIONS_DELETE_MARKED_FAIL,
  NOTIFICATIONS_ENTER_CLEARING_MODE,
} from '../actions/notifications';
import { ACCOUNT_BLOCK_SUCCESS } from '../actions/accounts';
import { TIMELINE_DELETE } from '../actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

const initialState = ImmutableMap({
  items: ImmutableList(),
  next: null,
  top: true,
  unread: 0,
  loaded: false,
  isLoading: true,
  cleaningMode: false,
});

const notificationToMap = notification => ImmutableMap({
  id: notification.id,
  type: notification.type,
  account: notification.account.id,
  markedForDelete: false,
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

const normalizeNotifications = (state, notifications, next) => {
  let items    = ImmutableList();
  const loaded = state.get('loaded');

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(n));
  });

  if (state.get('next') === null) {
    state = state.set('next', next);
  }

  return state
    .update('items', list => loaded ? items.concat(list) : list.concat(items))
    .set('loaded', true)
    .set('isLoading', false);
};

const appendNormalizedNotifications = (state, notifications, next) => {
  let items = ImmutableList();

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(n));
  });

  return state
    .update('items', list => list.concat(items))
    .set('next', next)
    .set('isLoading', false);
};

const filterNotifications = (state, relationship) => {
  return state.update('items', list => list.filterNot(item => item.get('account') === relationship.id));
};

const updateTop = (state, top) => {
  if (top) {
    state = state.set('unread', 0);
  }

  return state.set('top', top);
};

const deleteByStatus = (state, statusId) => {
  return state.update('items', list => list.filterNot(item => item.get('status') === statusId));
};

const markForDelete = (state, notificationId, yes) => {
  return state.update('items', list => list.map(item => {
    if(item.get('id') === notificationId) {
      return item.set('markedForDelete', yes);
    } else {
      return item;
    }
  }));
};

const unmarkAllForDelete = (state) => {
  return state.update('items', list => list.map(item => item.set('markedForDelete', false)));
};

const deleteMarkedNotifs = (state) => {
  return state.update('items', list => list.filterNot(item => item.get('markedForDelete')));
};

export default function notifications(state = initialState, action) {
  switch(action.type) {
  case NOTIFICATIONS_REFRESH_REQUEST:
  case NOTIFICATIONS_EXPAND_REQUEST:
  case NOTIFICATIONS_DELETE_MARKED_REQUEST:
    return state.set('isLoading', true);
  case NOTIFICATIONS_DELETE_MARKED_FAIL:
  case NOTIFICATIONS_REFRESH_FAIL:
  case NOTIFICATIONS_EXPAND_FAIL:
    return state.set('isLoading', false);
  case NOTIFICATIONS_SCROLL_TOP:
    return updateTop(state, action.top);
  case NOTIFICATIONS_UPDATE:
    return normalizeNotification(state, action.notification);
  case NOTIFICATIONS_REFRESH_SUCCESS:
    return normalizeNotifications(state, action.notifications, action.next);
  case NOTIFICATIONS_EXPAND_SUCCESS:
    return appendNormalizedNotifications(state, action.notifications, action.next);
  case ACCOUNT_BLOCK_SUCCESS:
    return filterNotifications(state, action.relationship);
  case NOTIFICATIONS_CLEAR:
    return state.set('items', ImmutableList()).set('next', null);
  case TIMELINE_DELETE:
    return deleteByStatus(state, action.id);
  case NOTIFICATION_MARK_FOR_DELETE:
    return markForDelete(state, action.id, action.yes);
  case NOTIFICATIONS_DELETE_MARKED_SUCCESS:
    return deleteMarkedNotifs(state).set('isLoading', false).set('cleaningMode', false);
  case NOTIFICATIONS_ENTER_CLEARING_MODE:
    const st = state.set('cleaningMode', action.yes);
    if (!action.yes)
      return unmarkAllForDelete(st);
    else return st;
  default:
    return state;
  }
};
