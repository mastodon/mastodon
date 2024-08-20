import { IntlMessageFormat } from 'intl-messageformat';
import { defineMessages } from 'react-intl';

import { List as ImmutableList } from 'immutable';

import { compareId } from 'mastodon/compare_id';
import { usePendingItems as preferPendingItems } from 'mastodon/initial_state';

import api, { getLinks } from '../api';
import { unescapeHTML } from '../utils/html';
import { requestNotificationPermission } from '../utils/notifications';

import { fetchFollowRequests, fetchRelationships } from './accounts';
import {
  importFetchedAccount,
  importFetchedAccounts,
  importFetchedStatus,
  importFetchedStatuses,
} from './importer';
import { submitMarkers } from './markers';
import { decreasePendingNotificationsCount } from './notification_policies';
import { notificationsUpdate } from "./notifications_typed";
import { register as registerPushNotifications } from './push_notifications';
import { saveSettings } from './settings';

export * from "./notifications_typed";

export const NOTIFICATIONS_UPDATE_NOOP = 'NOTIFICATIONS_UPDATE_NOOP';

export const NOTIFICATIONS_EXPAND_REQUEST = 'NOTIFICATIONS_EXPAND_REQUEST';
export const NOTIFICATIONS_EXPAND_SUCCESS = 'NOTIFICATIONS_EXPAND_SUCCESS';
export const NOTIFICATIONS_EXPAND_FAIL    = 'NOTIFICATIONS_EXPAND_FAIL';

export const NOTIFICATIONS_FILTER_SET = 'NOTIFICATIONS_FILTER_SET';

export const NOTIFICATIONS_SCROLL_TOP   = 'NOTIFICATIONS_SCROLL_TOP';
export const NOTIFICATIONS_LOAD_PENDING = 'NOTIFICATIONS_LOAD_PENDING';

export const NOTIFICATIONS_MOUNT   = 'NOTIFICATIONS_MOUNT';
export const NOTIFICATIONS_UNMOUNT = 'NOTIFICATIONS_UNMOUNT';

export const NOTIFICATIONS_MARK_AS_READ = 'NOTIFICATIONS_MARK_AS_READ';

export const NOTIFICATIONS_SET_BROWSER_SUPPORT    = 'NOTIFICATIONS_SET_BROWSER_SUPPORT';
export const NOTIFICATIONS_SET_BROWSER_PERMISSION = 'NOTIFICATIONS_SET_BROWSER_PERMISSION';

export const NOTIFICATION_REQUESTS_FETCH_REQUEST = 'NOTIFICATION_REQUESTS_FETCH_REQUEST';
export const NOTIFICATION_REQUESTS_FETCH_SUCCESS = 'NOTIFICATION_REQUESTS_FETCH_SUCCESS';
export const NOTIFICATION_REQUESTS_FETCH_FAIL    = 'NOTIFICATION_REQUESTS_FETCH_FAIL';

export const NOTIFICATION_REQUESTS_EXPAND_REQUEST = 'NOTIFICATION_REQUESTS_EXPAND_REQUEST';
export const NOTIFICATION_REQUESTS_EXPAND_SUCCESS = 'NOTIFICATION_REQUESTS_EXPAND_SUCCESS';
export const NOTIFICATION_REQUESTS_EXPAND_FAIL    = 'NOTIFICATION_REQUESTS_EXPAND_FAIL';

export const NOTIFICATION_REQUEST_FETCH_REQUEST = 'NOTIFICATION_REQUEST_FETCH_REQUEST';
export const NOTIFICATION_REQUEST_FETCH_SUCCESS = 'NOTIFICATION_REQUEST_FETCH_SUCCESS';
export const NOTIFICATION_REQUEST_FETCH_FAIL    = 'NOTIFICATION_REQUEST_FETCH_FAIL';

export const NOTIFICATION_REQUEST_ACCEPT_REQUEST = 'NOTIFICATION_REQUEST_ACCEPT_REQUEST';
export const NOTIFICATION_REQUEST_ACCEPT_SUCCESS = 'NOTIFICATION_REQUEST_ACCEPT_SUCCESS';
export const NOTIFICATION_REQUEST_ACCEPT_FAIL    = 'NOTIFICATION_REQUEST_ACCEPT_FAIL';

export const NOTIFICATION_REQUEST_DISMISS_REQUEST = 'NOTIFICATION_REQUEST_DISMISS_REQUEST';
export const NOTIFICATION_REQUEST_DISMISS_SUCCESS = 'NOTIFICATION_REQUEST_DISMISS_SUCCESS';
export const NOTIFICATION_REQUEST_DISMISS_FAIL    = 'NOTIFICATION_REQUEST_DISMISS_FAIL';

export const NOTIFICATION_REQUESTS_ACCEPT_REQUEST = 'NOTIFICATION_REQUESTS_ACCEPT_REQUEST';
export const NOTIFICATION_REQUESTS_ACCEPT_SUCCESS = 'NOTIFICATION_REQUESTS_ACCEPT_SUCCESS';
export const NOTIFICATION_REQUESTS_ACCEPT_FAIL    = 'NOTIFICATION_REQUESTS_ACCEPT_FAIL';

export const NOTIFICATION_REQUESTS_DISMISS_REQUEST = 'NOTIFICATION_REQUESTS_DISMISS_REQUEST';
export const NOTIFICATION_REQUESTS_DISMISS_SUCCESS = 'NOTIFICATION_REQUESTS_DISMISS_SUCCESS';
export const NOTIFICATION_REQUESTS_DISMISS_FAIL    = 'NOTIFICATION_REQUESTS_DISMISS_FAIL';

export const NOTIFICATIONS_FOR_REQUEST_FETCH_REQUEST = 'NOTIFICATIONS_FOR_REQUEST_FETCH_REQUEST';
export const NOTIFICATIONS_FOR_REQUEST_FETCH_SUCCESS = 'NOTIFICATIONS_FOR_REQUEST_FETCH_SUCCESS';
export const NOTIFICATIONS_FOR_REQUEST_FETCH_FAIL    = 'NOTIFICATIONS_FOR_REQUEST_FETCH_FAIL';

export const NOTIFICATIONS_FOR_REQUEST_EXPAND_REQUEST = 'NOTIFICATIONS_FOR_REQUEST_EXPAND_REQUEST';
export const NOTIFICATIONS_FOR_REQUEST_EXPAND_SUCCESS = 'NOTIFICATIONS_FOR_REQUEST_EXPAND_SUCCESS';
export const NOTIFICATIONS_FOR_REQUEST_EXPAND_FAIL    = 'NOTIFICATIONS_FOR_REQUEST_EXPAND_FAIL';

defineMessages({
  mention: { id: 'notification.mention', defaultMessage: '{name} mentioned you' },
  group: { id: 'notifications.group', defaultMessage: '{count} notifications' },
});

const fetchRelatedRelationships = (dispatch, notifications) => {
  const accountIds = notifications.filter(item => ['follow', 'follow_request', 'admin.sign_up'].indexOf(item.type) !== -1).map(item => item.account.id);

  if (accountIds.length > 0) {
    dispatch(fetchRelationships(accountIds));
  }
};

const selectNotificationCountForRequest = (state, id) => {
  const requests = state.getIn(['notificationRequests', 'items']);
  const thisRequest = requests.find(request => request.get('id') === id);
  return thisRequest ? thisRequest.get('notifications_count') : 0;
};

export const loadPending = () => ({
  type: NOTIFICATIONS_LOAD_PENDING,
});

export function updateNotifications(notification, intlMessages, intlLocale) {
  return (dispatch, getState) => {
    const activeFilter = getState().getIn(['settings', 'notifications', 'quickFilter', 'active']);
    const showInColumn = activeFilter === 'all' ? getState().getIn(['settings', 'notifications', 'shows', notification.type], true) : activeFilter === notification.type;
    const showAlert    = getState().getIn(['settings', 'notifications', 'alerts', notification.type], true);
    const playSound    = getState().getIn(['settings', 'notifications', 'sounds', notification.type], true);

    let filtered = false;

    if (['mention', 'status'].includes(notification.type) && notification.status.filtered) {
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

    if (showInColumn) {
      dispatch(importFetchedAccount(notification.account));

      if (notification.status) {
        dispatch(importFetchedStatus(notification.status));
      }

      if (notification.report) {
        dispatch(importFetchedAccount(notification.report.target_account));
      }


      dispatch(notificationsUpdate({ notification, preferPendingItems, playSound: playSound && !filtered}));

      fetchRelatedRelationships(dispatch, [notification]);
    } else if (playSound && !filtered) {
      dispatch({
        type: NOTIFICATIONS_UPDATE_NOOP,
        meta: { sound: 'boop' },
      });
    }

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

const excludeTypesFromSettings = state => state.getIn(['settings', 'notifications', 'shows']).filter(enabled => !enabled).keySeq().toJS();

const excludeTypesFromFilter = filter => {
  const allTypes = ImmutableList([
    'follow',
    'follow_request',
    'favourite',
    'reblog',
    'mention',
    'poll',
    'status',
    'update',
    'admin.sign_up',
    'admin.report',
  ]);

  return allTypes.filterNot(item => item === filter).toJS();
};

const noOp = () => {};

let expandNotificationsController = new AbortController();

export function expandNotifications({ maxId = undefined, forceLoad = false }) {
  return async (dispatch, getState) => {
    const activeFilter = getState().getIn(['settings', 'notifications', 'quickFilter', 'active']);
    const notifications = getState().get('notifications');
    const isLoadingMore = !!maxId;

    if (notifications.get('isLoading')) {
      if (forceLoad) {
        expandNotificationsController.abort();
        expandNotificationsController = new AbortController();
      } else {
        return;
      }
    }

    const params = {
      max_id: maxId,
      exclude_types: activeFilter === 'all'
        ? excludeTypesFromSettings(getState())
        : excludeTypesFromFilter(activeFilter),
    };

    if (!params.max_id && (notifications.get('items', ImmutableList()).size + notifications.get('pendingItems', ImmutableList()).size) > 0) {
      const a = notifications.getIn(['pendingItems', 0, 'id']);
      const b = notifications.getIn(['items', 0, 'id']);

      if (a && b && compareId(a, b) > 0) {
        params.since_id = a;
      } else {
        params.since_id = b || a;
      }
    }

    const isLoadingRecent = !!params.since_id;

    dispatch(expandNotificationsRequest(isLoadingMore));

    try {
      const response = await api().get('/api/v1/notifications', { params, signal: expandNotificationsController.signal });
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(importFetchedAccounts(response.data.map(item => item.account)));
      dispatch(importFetchedStatuses(response.data.map(item => item.status).filter(status => !!status)));
      dispatch(importFetchedAccounts(response.data.filter(item => item.report).map(item => item.report.target_account)));

      dispatch(expandNotificationsSuccess(response.data, next ? next.uri : null, isLoadingMore, isLoadingRecent, isLoadingRecent && preferPendingItems));
      fetchRelatedRelationships(dispatch, response.data);
      dispatch(submitMarkers());
    } catch(error) {
      dispatch(expandNotificationsFail(error, isLoadingMore));
    }
  };
}

export function expandNotificationsRequest(isLoadingMore) {
  return {
    type: NOTIFICATIONS_EXPAND_REQUEST,
    skipLoading: !isLoadingMore,
  };
}

export function expandNotificationsSuccess(notifications, next, isLoadingMore, isLoadingRecent, usePendingItems) {
  return {
    type: NOTIFICATIONS_EXPAND_SUCCESS,
    notifications,
    next,
    isLoadingRecent: isLoadingRecent,
    usePendingItems,
    skipLoading: !isLoadingMore,
  };
}

export function expandNotificationsFail(error, isLoadingMore) {
  return {
    type: NOTIFICATIONS_EXPAND_FAIL,
    error,
    skipLoading: !isLoadingMore,
    skipAlert: !isLoadingMore || error.name === 'AbortError',
  };
}

export function scrollTopNotifications(top) {
  return {
    type: NOTIFICATIONS_SCROLL_TOP,
    top,
  };
}

export function setFilter (filterType) {
  return dispatch => {
    dispatch({
      type: NOTIFICATIONS_FILTER_SET,
      path: ['notifications', 'quickFilter', 'active'],
      value: filterType,
    });
    dispatch(expandNotifications({ forceLoad: true }));
    dispatch(saveSettings());
  };
}

export const mountNotifications = () => ({
  type: NOTIFICATIONS_MOUNT,
});

export const unmountNotifications = () => ({
  type: NOTIFICATIONS_UNMOUNT,
});


export const markNotificationsAsRead = () => ({
  type: NOTIFICATIONS_MARK_AS_READ,
});

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

export const fetchNotificationRequests = () => (dispatch, getState) => {
  const params = {};

  if (getState().getIn(['notificationRequests', 'isLoading'])) {
    return;
  }

  if (getState().getIn(['notificationRequests', 'items'])?.size > 0) {
    params.since_id = getState().getIn(['notificationRequests', 'items', 0, 'id']);
  }

  dispatch(fetchNotificationRequestsRequest());

  api().get('/api/v1/notifications/requests', { params }).then(response => {
    const next = getLinks(response).refs.find(link => link.rel === 'next');
    dispatch(importFetchedAccounts(response.data.map(x => x.account)));
    dispatch(fetchNotificationRequestsSuccess(response.data, next ? next.uri : null));
  }).catch(err => {
    dispatch(fetchNotificationRequestsFail(err));
  });
};

export const fetchNotificationRequestsRequest = () => ({
  type: NOTIFICATION_REQUESTS_FETCH_REQUEST,
});

export const fetchNotificationRequestsSuccess = (requests, next) => ({
  type: NOTIFICATION_REQUESTS_FETCH_SUCCESS,
  requests,
  next,
});

export const fetchNotificationRequestsFail = error => ({
  type: NOTIFICATION_REQUESTS_FETCH_FAIL,
  error,
});

export const expandNotificationRequests = () => (dispatch, getState) => {
  const url = getState().getIn(['notificationRequests', 'next']);

  if (!url || getState().getIn(['notificationRequests', 'isLoading'])) {
    return;
  }

  dispatch(expandNotificationRequestsRequest());

  api().get(url).then(response => {
    const next = getLinks(response).refs.find(link => link.rel === 'next');
    dispatch(importFetchedAccounts(response.data.map(x => x.account)));
    dispatch(expandNotificationRequestsSuccess(response.data, next?.uri));
  }).catch(err => {
    dispatch(expandNotificationRequestsFail(err));
  });
};

export const expandNotificationRequestsRequest = () => ({
  type: NOTIFICATION_REQUESTS_EXPAND_REQUEST,
});

export const expandNotificationRequestsSuccess = (requests, next) => ({
  type: NOTIFICATION_REQUESTS_EXPAND_SUCCESS,
  requests,
  next,
});

export const expandNotificationRequestsFail = error => ({
  type: NOTIFICATION_REQUESTS_EXPAND_FAIL,
  error,
});

export const fetchNotificationRequest = id => (dispatch, getState) => {
  const current = getState().getIn(['notificationRequests', 'current']);

  if (current.getIn(['item', 'id']) === id || current.get('isLoading')) {
    return;
  }

  dispatch(fetchNotificationRequestRequest(id));

  api().get(`/api/v1/notifications/requests/${id}`).then(({ data }) => {
    dispatch(fetchNotificationRequestSuccess(data));
  }).catch(err => {
    dispatch(fetchNotificationRequestFail(id, err));
  });
};

export const fetchNotificationRequestRequest = id => ({
  type: NOTIFICATION_REQUEST_FETCH_REQUEST,
  id,
});

export const fetchNotificationRequestSuccess = request => ({
  type: NOTIFICATION_REQUEST_FETCH_SUCCESS,
  request,
});

export const fetchNotificationRequestFail = (id, error) => ({
  type: NOTIFICATION_REQUEST_FETCH_FAIL,
  id,
  error,
});

export const acceptNotificationRequest = (id) => (dispatch, getState) => {
  const count = selectNotificationCountForRequest(getState(), id);
  dispatch(acceptNotificationRequestRequest(id));

  api().post(`/api/v1/notifications/requests/${id}/accept`).then(() => {
    dispatch(acceptNotificationRequestSuccess(id));
    dispatch(decreasePendingNotificationsCount(count));
  }).catch(err => {
    dispatch(acceptNotificationRequestFail(id, err));
  });
};

export const acceptNotificationRequestRequest = id => ({
  type: NOTIFICATION_REQUEST_ACCEPT_REQUEST,
  id,
});

export const acceptNotificationRequestSuccess = id => ({
  type: NOTIFICATION_REQUEST_ACCEPT_SUCCESS,
  id,
});

export const acceptNotificationRequestFail = (id, error) => ({
  type: NOTIFICATION_REQUEST_ACCEPT_FAIL,
  id,
  error,
});

export const dismissNotificationRequest = (id) => (dispatch, getState) => {
  const count = selectNotificationCountForRequest(getState(), id);
  dispatch(dismissNotificationRequestRequest(id));

  api().post(`/api/v1/notifications/requests/${id}/dismiss`).then(() =>{
    dispatch(dismissNotificationRequestSuccess(id));
    dispatch(decreasePendingNotificationsCount(count));
  }).catch(err => {
    dispatch(dismissNotificationRequestFail(id, err));
  });
};

export const dismissNotificationRequestRequest = id => ({
  type: NOTIFICATION_REQUEST_DISMISS_REQUEST,
  id,
});

export const dismissNotificationRequestSuccess = id => ({
  type: NOTIFICATION_REQUEST_DISMISS_SUCCESS,
  id,
});

export const dismissNotificationRequestFail = (id, error) => ({
  type: NOTIFICATION_REQUEST_DISMISS_FAIL,
  id,
  error,
});

export const acceptNotificationRequests = (ids) => (dispatch, getState) => {
  const count = ids.reduce((count, id) => count + selectNotificationCountForRequest(getState(), id), 0);
  dispatch(acceptNotificationRequestsRequest(ids));

  api().post(`/api/v1/notifications/requests/accept`, { id: ids }).then(() => {
    dispatch(acceptNotificationRequestsSuccess(ids));
    dispatch(decreasePendingNotificationsCount(count));
  }).catch(err => {
    dispatch(acceptNotificationRequestFail(ids, err));
  });
};

export const acceptNotificationRequestsRequest = ids => ({
  type: NOTIFICATION_REQUESTS_ACCEPT_REQUEST,
  ids,
});

export const acceptNotificationRequestsSuccess = ids => ({
  type: NOTIFICATION_REQUESTS_ACCEPT_SUCCESS,
  ids,
});

export const acceptNotificationRequestsFail = (ids, error) => ({
  type: NOTIFICATION_REQUESTS_ACCEPT_FAIL,
  ids,
  error,
});

export const dismissNotificationRequests = (ids) => (dispatch, getState) => {
  const count = ids.reduce((count, id) => count + selectNotificationCountForRequest(getState(), id), 0);
  dispatch(acceptNotificationRequestsRequest(ids));

  api().post(`/api/v1/notifications/requests/dismiss`, { id: ids }).then(() => {
    dispatch(dismissNotificationRequestsSuccess(ids));
    dispatch(decreasePendingNotificationsCount(count));
  }).catch(err => {
    dispatch(dismissNotificationRequestFail(ids, err));
  });
};

export const dismissNotificationRequestsRequest = ids => ({
  type: NOTIFICATION_REQUESTS_DISMISS_REQUEST,
  ids,
});

export const dismissNotificationRequestsSuccess = ids => ({
  type: NOTIFICATION_REQUESTS_DISMISS_SUCCESS,
  ids,
});

export const dismissNotificationRequestsFail = (ids, error) => ({
  type: NOTIFICATION_REQUESTS_DISMISS_FAIL,
  ids,
  error,
});

export const fetchNotificationsForRequest = accountId => (dispatch, getState) => {
  const current = getState().getIn(['notificationRequests', 'current']);
  const params = { account_id: accountId };

  if (current.getIn(['item', 'account']) === accountId) {
    if (current.getIn(['notifications', 'isLoading'])) {
      return;
    }

    if (current.getIn(['notifications', 'items'])?.size > 0) {
      params.since_id = current.getIn(['notifications', 'items', 0, 'id']);
    }
  }

  dispatch(fetchNotificationsForRequestRequest());

  api().get('/api/v1/notifications', { params }).then(response => {
    const next = getLinks(response).refs.find(link => link.rel === 'next');
    dispatch(importFetchedAccounts(response.data.map(item => item.account)));
    dispatch(importFetchedStatuses(response.data.map(item => item.status).filter(status => !!status)));
    dispatch(importFetchedAccounts(response.data.filter(item => item.report).map(item => item.report.target_account)));

    dispatch(fetchNotificationsForRequestSuccess(response.data, next?.uri));
  }).catch(err => {
    dispatch(fetchNotificationsForRequestFail(err));
  });
};

export const fetchNotificationsForRequestRequest = () => ({
  type: NOTIFICATIONS_FOR_REQUEST_FETCH_REQUEST,
});

export const fetchNotificationsForRequestSuccess = (notifications, next) => ({
  type: NOTIFICATIONS_FOR_REQUEST_FETCH_SUCCESS,
  notifications,
  next,
});

export const fetchNotificationsForRequestFail = (error) => ({
  type: NOTIFICATIONS_FOR_REQUEST_FETCH_FAIL,
  error,
});

export const expandNotificationsForRequest = () => (dispatch, getState) => {
  const url = getState().getIn(['notificationRequests', 'current', 'notifications', 'next']);

  if (!url || getState().getIn(['notificationRequests', 'current', 'notifications', 'isLoading'])) {
    return;
  }

  dispatch(expandNotificationsForRequestRequest());

  api().get(url).then(response => {
    const next = getLinks(response).refs.find(link => link.rel === 'next');
    dispatch(importFetchedAccounts(response.data.map(item => item.account)));
    dispatch(importFetchedStatuses(response.data.map(item => item.status).filter(status => !!status)));
    dispatch(importFetchedAccounts(response.data.filter(item => item.report).map(item => item.report.target_account)));

    dispatch(expandNotificationsForRequestSuccess(response.data, next?.uri));
  }).catch(err => {
    dispatch(expandNotificationsForRequestFail(err));
  });
};

export const expandNotificationsForRequestRequest = () => ({
  type: NOTIFICATIONS_FOR_REQUEST_EXPAND_REQUEST,
});

export const expandNotificationsForRequestSuccess = (notifications, next) => ({
  type: NOTIFICATIONS_FOR_REQUEST_EXPAND_SUCCESS,
  notifications,
  next,
});

export const expandNotificationsForRequestFail = (error) => ({
  type: NOTIFICATIONS_FOR_REQUEST_EXPAND_FAIL,
  error,
});
