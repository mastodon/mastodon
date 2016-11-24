import {
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_REFRESH_SUCCESS,
  NOTIFICATIONS_EXPAND_SUCCESS
} from '../actions/notifications';
import { ACCOUNT_BLOCK_SUCCESS } from '../actions/accounts';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  items: Immutable.List(),
  next: null,
  loaded: false
});

const notificationToMap = notification => Immutable.Map({
  id: notification.id,
  type: notification.type,
  account: notification.account.id,
  status: notification.status ? notification.status.id : null
});

const normalizeNotification = (state, notification) => {
  return state.update('items', list => list.unshift(notificationToMap(notification)));
};

const normalizeNotifications = (state, notifications, next) => {
  let items    = Immutable.List();
  const loaded = state.get('loaded');

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(n));
  });

  return state.update('items', list => loaded ? list.unshift(...items) : list.push(...items)).set('next', next).set('loaded', true);
};

const appendNormalizedNotifications = (state, notifications, next) => {
  let items = Immutable.List();

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(n));
  });

  return state.update('items', list => list.push(...items)).set('next', next);
};

const filterNotifications = (state, relationship) => {
  return state.update('items', list => list.filterNot(item => item.get('account') === relationship.id));
};

export default function notifications(state = initialState, action) {
  switch(action.type) {
    case NOTIFICATIONS_UPDATE:
      return normalizeNotification(state, action.notification);
    case NOTIFICATIONS_REFRESH_SUCCESS:
      return normalizeNotifications(state, action.notifications, action.next);
    case NOTIFICATIONS_EXPAND_SUCCESS:
      return appendNormalizedNotifications(state, action.notifications, action.next);
    case ACCOUNT_BLOCK_SUCCESS:
      return filterNotifications(state, action.relationship);
    default:
      return state;
  }
};
