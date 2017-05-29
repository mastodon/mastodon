import api, { getLinks } from '../api';
import Immutable from 'immutable';
import IntlMessageFormat from 'intl-messageformat';
import { fetchRelationships } from './accounts';
import { defineMessages } from 'react-intl';

export const NOTIFICATIONS_UPDATE = 'NOTIFICATIONS_UPDATE';

export const NOTIFICATIONS_REFRESH_REQUEST = 'NOTIFICATIONS_REFRESH_REQUEST';
export const NOTIFICATIONS_REFRESH_SUCCESS = 'NOTIFICATIONS_REFRESH_SUCCESS';
export const NOTIFICATIONS_REFRESH_FAIL    = 'NOTIFICATIONS_REFRESH_FAIL';

export const NOTIFICATIONS_EXPAND_REQUEST = 'NOTIFICATIONS_EXPAND_REQUEST';
export const NOTIFICATIONS_EXPAND_SUCCESS = 'NOTIFICATIONS_EXPAND_SUCCESS';
export const NOTIFICATIONS_EXPAND_FAIL    = 'NOTIFICATIONS_EXPAND_FAIL';

export const NOTIFICATIONS_CLEAR      = 'NOTIFICATIONS_CLEAR';
export const NOTIFICATIONS_SCROLL_TOP = 'NOTIFICATIONS_SCROLL_TOP';

const messages = defineMessages({
  mention: { id: 'notification.mention', defaultMessage: '{name} mentioned you' },
});

const fetchRelatedRelationships = (dispatch, notifications) => {
  const accountIds = notifications.filter(item => item.type === 'follow').map(item => item.account.id);

  if (accountIds > 0) {
    dispatch(fetchRelationships(accountIds));
  }
};

const unescapeHTML = (html) => {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = html;
  return wrapper.textContent;
};

export function updateNotifications(notification, intlMessages, intlLocale) {
  return (dispatch, getState) => {
    const showAlert = getState().getIn(['settings', 'notifications', 'alerts', notification.type], true);
    const playSound = getState().getIn(['settings', 'notifications', 'sounds', notification.type], true);

    dispatch({
      type: NOTIFICATIONS_UPDATE,
      notification,
      account: notification.account,
      status: notification.status,
      meta: playSound ? { sound: 'boop' } : undefined,
    });

    fetchRelatedRelationships(dispatch, [notification]);

    // Desktop notifications
    if (typeof window.Notification !== 'undefined' && showAlert) {
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

export function refreshNotifications() {
  return (dispatch, getState) => {
    const params = {};
    const ids    = getState().getIn(['notifications', 'items']);

    let skipLoading = false;

    if (ids.size > 0) {
      params.since_id = ids.first().get('id');
    }

    if (getState().getIn(['notifications', 'loaded'])) {
      skipLoading = true;
    }

    params.exclude_types = excludeTypesFromSettings(getState());

    dispatch(refreshNotificationsRequest(skipLoading));

    api(getState).get('/api/v1/notifications', { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(refreshNotificationsSuccess(response.data, skipLoading, next ? next.uri : null));
      fetchRelatedRelationships(dispatch, response.data);
    }).catch(error => {
      dispatch(refreshNotificationsFail(error, skipLoading));
    });
  };
};

export function refreshNotificationsRequest(skipLoading) {
  return {
    type: NOTIFICATIONS_REFRESH_REQUEST,
    skipLoading,
  };
};

export function refreshNotificationsSuccess(notifications, skipLoading, next) {
  return {
    type: NOTIFICATIONS_REFRESH_SUCCESS,
    notifications,
    accounts: notifications.map(item => item.account),
    statuses: notifications.map(item => item.status).filter(status => !!status),
    skipLoading,
    next,
  };
};

export function refreshNotificationsFail(error, skipLoading) {
  return {
    type: NOTIFICATIONS_REFRESH_FAIL,
    error,
    skipLoading,
  };
};

export function expandNotifications() {
  return (dispatch, getState) => {
    const url    = getState().getIn(['notifications', 'next'], null);
    const lastId = getState().getIn(['notifications', 'items']).last();

    if (url === null || getState().getIn(['notifications', 'isLoading'])) {
      return;
    }

    dispatch(expandNotificationsRequest());

    const params = {
      max_id: lastId,
      limit: 20,
    };

    params.exclude_types = excludeTypesFromSettings(getState());

    api(getState).get(url, params).then(response => {
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
