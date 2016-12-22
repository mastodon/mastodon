import api, { getLinks } from '../api'
import Immutable from 'immutable';
import IntlMessageFormat from 'intl-messageformat';

import { fetchRelationships } from './accounts';

export const NOTIFICATIONS_UPDATE = 'NOTIFICATIONS_UPDATE';

export const NOTIFICATIONS_REFRESH_REQUEST = 'NOTIFICATIONS_REFRESH_REQUEST';
export const NOTIFICATIONS_REFRESH_SUCCESS = 'NOTIFICATIONS_REFRESH_SUCCESS';
export const NOTIFICATIONS_REFRESH_FAIL    = 'NOTIFICATIONS_REFRESH_FAIL';

export const NOTIFICATIONS_EXPAND_REQUEST = 'NOTIFICATIONS_EXPAND_REQUEST';
export const NOTIFICATIONS_EXPAND_SUCCESS = 'NOTIFICATIONS_EXPAND_SUCCESS';
export const NOTIFICATIONS_EXPAND_FAIL    = 'NOTIFICATIONS_EXPAND_FAIL';

const fetchRelatedRelationships = (dispatch, notifications) => {
  const accountIds = notifications.filter(item => item.type === 'follow').map(item => item.account.id);

  if (accountIds > 0) {
    dispatch(fetchRelationships(accountIds));
  }
};

export function updateNotifications(notification, intlMessages, intlLocale) {
  return dispatch => {
    dispatch({
      type: NOTIFICATIONS_UPDATE,
      notification,
      account: notification.account,
      status: notification.status
    });

    fetchRelatedRelationships(dispatch, [notification]);

    // Desktop notifications
    if (typeof window.Notification !== 'undefined') {
      const title = new IntlMessageFormat(intlMessages[`notification.${notification.type}`], intlLocale).format({ name: notification.account.display_name.length > 0 ? notification.account.display_name : notification.account.username });
      const body  = $('<p>').html(notification.status ? notification.status.content : '').text();

      new Notification(title, { body, icon: notification.account.avatar });
    }
  };
};

export function refreshNotifications() {
  return (dispatch, getState) => {
    dispatch(refreshNotificationsRequest());

    const params = {};
    const ids    = getState().getIn(['notifications', 'items']);

    if (ids.size > 0) {
      params.since_id = ids.first().get('id');
    }

    api(getState).get('/api/v1/notifications', { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(refreshNotificationsSuccess(response.data, next ? next.uri : null));
      fetchRelatedRelationships(dispatch, response.data);
    }).catch(error => {
      dispatch(refreshNotificationsFail(error));
    });
  };
};

export function refreshNotificationsRequest() {
  return {
    type: NOTIFICATIONS_REFRESH_REQUEST
  };
};

export function refreshNotificationsSuccess(notifications, next) {
  return {
    type: NOTIFICATIONS_REFRESH_SUCCESS,
    notifications,
    accounts: notifications.map(item => item.account),
    statuses: notifications.map(item => item.status).filter(status => !!status),
    next
  };
};

export function refreshNotificationsFail(error) {
  return {
    type: NOTIFICATIONS_REFRESH_FAIL,
    error
  };
};

export function expandNotifications() {
  return (dispatch, getState) => {
    const url = getState().getIn(['notifications', 'next'], null);

    if (url === null) {
      return;
    }

    dispatch(expandNotificationsRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(expandNotificationsSuccess(response.data, next ? next.uri : null));
      fetchRelatedRelationships(dispatch, response.data);
    }).catch(error => {
      dispatch(expandNotificationsFail(error));
    });
  };
};

export function expandNotificationsRequest() {
  return {
    type: NOTIFICATIONS_EXPAND_REQUEST
  };
};

export function expandNotificationsSuccess(notifications, next) {
  return {
    type: NOTIFICATIONS_EXPAND_SUCCESS,
    notifications,
    accounts: notifications.map(item => item.account),
    statuses: notifications.map(item => item.status).filter(status => !!status),
    next
  };
};

export function expandNotificationsFail(error) {
  return {
    type: NOTIFICATIONS_EXPAND_FAIL,
    error
  };
};
