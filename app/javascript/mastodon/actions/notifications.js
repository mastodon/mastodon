import { IntlMessageFormat } from 'intl-messageformat';
import { defineMessages } from 'react-intl';

import { unescapeHTML } from '../utils/html';
import { requestNotificationPermission } from '../utils/notifications';

import { fetchFollowRequests } from './accounts';
import {
  importFetchedAccount,
} from './importer';
import { submitMarkers } from './markers';
import { notificationsUpdate } from "./notifications_typed";
import { register as registerPushNotifications } from './push_notifications';

export * from "./notifications_typed";

export const NOTIFICATIONS_FILTER_SET = 'NOTIFICATIONS_FILTER_SET';

export const NOTIFICATIONS_SET_BROWSER_SUPPORT    = 'NOTIFICATIONS_SET_BROWSER_SUPPORT';
export const NOTIFICATIONS_SET_BROWSER_PERMISSION = 'NOTIFICATIONS_SET_BROWSER_PERMISSION';

defineMessages({
  mention: { id: 'notification.mention', defaultMessage: '{name} mentioned you' },
  group: { id: 'notifications.group', defaultMessage: '{count} notifications' },
});

export function updateNotifications(notification, intlMessages, intlLocale) {
  return (dispatch, getState) => {
    const showAlert    = getState().getIn(['settings', 'notifications', 'alerts', notification.type], true);
    const playSound    = getState().getIn(['settings', 'notifications', 'sounds', notification.type], true);

    let filtered = false;

    if (['mention', 'quote', 'status'].includes(notification.type) && notification.status.filtered) {
      const filters = notification.status.filtered.filter(result => result.filter.context.includes('notifications'));

      if (filters.some(result => result.filter.filter_action === 'hide')) {
        return;
      }

      filtered = filters.length > 0;
    }

    if (['follow_request'].includes(notification.type)) {
      dispatch(fetchFollowRequests());
    }

    dispatch(submitMarkers());

    // `notificationsUpdate` is still used in `user_lists` and `relationships` reducers
    dispatch(importFetchedAccount(notification.account));
    dispatch(notificationsUpdate({ notification, playSound: playSound && !filtered}));

    // Desktop notifications
    if (typeof window.Notification !== 'undefined' && showAlert && !filtered) {
      const title = new IntlMessageFormat(intlMessages[`notification.${notification.type}`], intlLocale).format({ name: notification.account.display_name.length > 0 ? notification.account.display_name : notification.account.username });
      const body  = (notification.status && notification.status.spoiler_text.length > 0) ? notification.status.spoiler_text : unescapeHTML(notification.status ? notification.status.content : '');

      const notify = new Notification(title, { body, icon: notification.account.avatar, tag: notification.id });

      notify.addEventListener('click', () => {
        window.focus();
        notify.close();
      });
    }
  };
}

const noOp = () => {};

// Browser support
export function setupBrowserNotifications() {
  return dispatch => {
    dispatch(setBrowserSupport('Notification' in window));
    if ('Notification' in window) {
      dispatch(setBrowserPermission(Notification.permission));
    }

    if ('Notification' in window && 'permissions' in navigator) {
      navigator.permissions.query({ name: 'notifications' }).then((status) => {
        status.onchange = () => dispatch(setBrowserPermission(Notification.permission));
      }).catch(console.warn);
    }
  };
}

export function requestBrowserPermission(callback = noOp) {
  return dispatch => {
    requestNotificationPermission((permission) => {
      dispatch(setBrowserPermission(permission));
      callback(permission);

      if (permission === 'granted') {
        dispatch(registerPushNotifications());
      }
    });
  };
}

export function setBrowserSupport (value) {
  return {
    type: NOTIFICATIONS_SET_BROWSER_SUPPORT,
    value,
  };
}

export function setBrowserPermission (value) {
  return {
    type: NOTIFICATIONS_SET_BROWSER_PERMISSION,
    value,
  };
}
