import { fromJS, Map as ImmutableMap } from 'immutable';

import {
  NOTIFICATIONS_SET_BROWSER_SUPPORT,
  NOTIFICATIONS_SET_BROWSER_PERMISSION,
} from '../actions/notifications';

const initialState = ImmutableMap({
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

export default function notifications(state = initialState, action) {
  switch(action.type) {
  case NOTIFICATIONS_SET_BROWSER_SUPPORT:
    return state.set('browserSupport', action.value);
  case NOTIFICATIONS_SET_BROWSER_PERMISSION:
    return state.set('browserPermission', action.value);
  default:
    return state;
  }
}
