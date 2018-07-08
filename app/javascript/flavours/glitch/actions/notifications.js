import api, { getLinks } from 'flavours/glitch/util/api';
import IntlMessageFormat from 'intl-messageformat';
import { fetchRelationships } from './accounts';
import { defineMessages } from 'react-intl';
import { unescapeHTML } from 'flavours/glitch/util/html';
import { getFilters, regexFromFilters } from 'flavours/glitch/selectors';

export const NOTIFICATIONS_UPDATE = 'NOTIFICATIONS_UPDATE';

// tracking the notif cleaning request
export const NOTIFICATIONS_DELETE_MARKED_REQUEST = 'NOTIFICATIONS_DELETE_MARKED_REQUEST';
export const NOTIFICATIONS_DELETE_MARKED_SUCCESS = 'NOTIFICATIONS_DELETE_MARKED_SUCCESS';
export const NOTIFICATIONS_DELETE_MARKED_FAIL = 'NOTIFICATIONS_DELETE_MARKED_FAIL';
export const NOTIFICATIONS_MARK_ALL_FOR_DELETE = 'NOTIFICATIONS_MARK_ALL_FOR_DELETE';
export const NOTIFICATIONS_ENTER_CLEARING_MODE = 'NOTIFICATIONS_ENTER_CLEARING_MODE'; // arg: yes
// Unmark notifications (when the cleaning mode is left)
export const NOTIFICATIONS_UNMARK_ALL_FOR_DELETE = 'NOTIFICATIONS_UNMARK_ALL_FOR_DELETE';
// Mark one for delete
export const NOTIFICATION_MARK_FOR_DELETE = 'NOTIFICATION_MARK_FOR_DELETE';

export const NOTIFICATIONS_EXPAND_REQUEST = 'NOTIFICATIONS_EXPAND_REQUEST';
export const NOTIFICATIONS_EXPAND_SUCCESS = 'NOTIFICATIONS_EXPAND_SUCCESS';
export const NOTIFICATIONS_EXPAND_FAIL    = 'NOTIFICATIONS_EXPAND_FAIL';

export const NOTIFICATIONS_CLEAR      = 'NOTIFICATIONS_CLEAR';
export const NOTIFICATIONS_SCROLL_TOP = 'NOTIFICATIONS_SCROLL_TOP';

defineMessages({
  mention: { id: 'notification.mention', defaultMessage: '{name} mentioned you' },
});

const fetchRelatedRelationships = (dispatch, notifications) => {
  const accountIds = notifications.filter(item => item.type === 'follow').map(item => item.account.id);

  if (accountIds > 0) {
    dispatch(fetchRelationships(accountIds));
  }
};

export function updateNotifications(notification, intlMessages, intlLocale) {
  return (dispatch, getState) => {
    const showAlert = getState().getIn(['settings', 'notifications', 'alerts', notification.type], true);
    const playSound = getState().getIn(['settings', 'notifications', 'sounds', notification.type], true);
    const filters   = getFilters(getState(), { contextType: 'notifications' });

    let filtered = false;

    if (notification.type === 'mention') {
      const regex       = regexFromFilters(filters);
      const searchIndex = notification.status.spoiler_text + '\n' + unescapeHTML(notification.status.content);

      filtered = regex && regex.test(searchIndex);
    }

    dispatch({
      type: NOTIFICATIONS_UPDATE,
      notification,
      account: notification.account,
      status: notification.status,
      meta: (playSound && !filtered) ? { sound: 'boop' } : undefined,
    });

    fetchRelatedRelationships(dispatch, [notification]);

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
};

const excludeTypesFromSettings = state => state.getIn(['settings', 'notifications', 'shows']).filter(enabled => !enabled).keySeq().toJS();


const noOp = () => {};

export function expandNotifications({ maxId } = {}, done = noOp) {
  return (dispatch, getState) => {
    const notifications = getState().get('notifications');

    if (notifications.get('isLoading')) {
      done();
      return;
    }

    const params = {
      max_id: maxId,
      exclude_types: excludeTypesFromSettings(getState()),
    };

    if (!maxId && notifications.get('items').size > 0) {
      params.since_id = notifications.getIn(['items', 0]);
    }

    dispatch(expandNotificationsRequest());

    api(getState).get('/api/v1/notifications', { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandNotificationsSuccess(response.data, next ? next.uri : null));
      fetchRelatedRelationships(dispatch, response.data);
      done();
    }).catch(error => {
      dispatch(expandNotificationsFail(error));
      done();
    });
  };
};

export function expandNotificationsRequest() {
  return {
    type: NOTIFICATIONS_EXPAND_REQUEST,
  };
};

export function expandNotificationsSuccess(notifications, next) {
  return {
    type: NOTIFICATIONS_EXPAND_SUCCESS,
    notifications,
    accounts: notifications.map(item => item.account),
    statuses: notifications.map(item => item.status).filter(status => !!status),
    next,
  };
};

export function expandNotificationsFail(error) {
  return {
    type: NOTIFICATIONS_EXPAND_FAIL,
    error,
  };
};

export function clearNotifications() {
  return (dispatch, getState) => {
    dispatch({
      type: NOTIFICATIONS_CLEAR,
    });

    api(getState).post('/api/v1/notifications/clear');
  };
};

export function scrollTopNotifications(top) {
  return {
    type: NOTIFICATIONS_SCROLL_TOP,
    top,
  };
};

export function deleteMarkedNotifications() {
  return (dispatch, getState) => {
    dispatch(deleteMarkedNotificationsRequest());

    let ids = [];
    getState().getIn(['notifications', 'items']).forEach((n) => {
      if (n.get('markedForDelete')) {
        ids.push(n.get('id'));
      }
    });

    if (ids.length === 0) {
      return;
    }

    api(getState).delete(`/api/v1/notifications/destroy_multiple?ids[]=${ids.join('&ids[]=')}`).then(() => {
      dispatch(deleteMarkedNotificationsSuccess());
    }).catch(error => {
      console.error(error);
      dispatch(deleteMarkedNotificationsFail(error));
    });
  };
};

export function enterNotificationClearingMode(yes) {
  return {
    type: NOTIFICATIONS_ENTER_CLEARING_MODE,
    yes: yes,
  };
};

export function markAllNotifications(yes) {
  return {
    type: NOTIFICATIONS_MARK_ALL_FOR_DELETE,
    yes: yes, // true, false or null. null = invert
  };
};

export function deleteMarkedNotificationsRequest() {
  return {
    type: NOTIFICATIONS_DELETE_MARKED_REQUEST,
  };
};

export function deleteMarkedNotificationsFail() {
  return {
    type: NOTIFICATIONS_DELETE_MARKED_FAIL,
  };
};

export function markNotificationForDelete(id, yes) {
  return {
    type: NOTIFICATION_MARK_FOR_DELETE,
    id: id,
    yes: yes,
  };
};

export function deleteMarkedNotificationsSuccess() {
  return {
    type: NOTIFICATIONS_DELETE_MARKED_SUCCESS,
  };
};
