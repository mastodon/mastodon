import api, { getLinks } from '../api';
import IntlMessageFormat from 'intl-messageformat';
import { fetchRelationships } from './accounts';
import {
  importFetchedAccount,
  importFetchedAccounts,
  importFetchedStatus,
  importFetchedStatuses,
} from './importer';
import { defineMessages } from 'react-intl';
import { unescapeHTML } from '../utils/html';
import { getFilters, regexFromFilters } from '../selectors';

export const NOTIFICATIONS_UPDATE      = 'NOTIFICATIONS_UPDATE';
export const NOTIFICATIONS_UPDATE_NOOP = 'NOTIFICATIONS_UPDATE_NOOP';

export const NOTIFICATIONS_EXPAND_REQUEST = 'NOTIFICATIONS_EXPAND_REQUEST';
export const NOTIFICATIONS_EXPAND_SUCCESS = 'NOTIFICATIONS_EXPAND_SUCCESS';
export const NOTIFICATIONS_EXPAND_FAIL    = 'NOTIFICATIONS_EXPAND_FAIL';

export const NOTIFICATIONS_CLEAR      = 'NOTIFICATIONS_CLEAR';
export const NOTIFICATIONS_SCROLL_TOP = 'NOTIFICATIONS_SCROLL_TOP';

defineMessages({
  mention: { id: 'notification.mention', defaultMessage: '{name} mentioned you' },
  group: { id: 'notifications.group', defaultMessage: '{count} notifications' },
});

const fetchRelatedRelationships = (dispatch, notifications) => {
  const accountIds = notifications.filter(item => item.type === 'follow').map(item => item.account.id);

  if (accountIds.length > 0) {
    dispatch(fetchRelationships(accountIds));
  }
};

export function updateNotifications(notification, intlMessages, intlLocale) {
  return (dispatch, getState) => {
    const showInColumn = getState().getIn(['settings', 'notifications', 'shows', notification.type], true);
    const showAlert    = getState().getIn(['settings', 'notifications', 'alerts', notification.type], true);
    const playSound    = getState().getIn(['settings', 'notifications', 'sounds', notification.type], true);
    const filters      = getFilters(getState(), { contextType: 'notifications' });

    let filtered = false;

    if (notification.type === 'mention') {
      const regex       = regexFromFilters(filters);
      const searchIndex = notification.status.spoiler_text + '\n' + unescapeHTML(notification.status.content);

      filtered = regex && regex.test(searchIndex);
    }

    if (showInColumn) {
      dispatch(importFetchedAccount(notification.account));

      if (notification.status) {
        dispatch(importFetchedStatus(notification.status));
      }

      dispatch({
        type: NOTIFICATIONS_UPDATE,
        notification,
        meta: (playSound && !filtered) ? { sound: 'boop' } : undefined,
      });

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
};

const excludeTypesFromSettings = state => state.getIn(['settings', 'notifications', 'shows']).filter(enabled => !enabled).keySeq().toJS();

const noOp = () => {};

export function expandNotifications({ maxId } = {}, done = noOp) {
  return (dispatch, getState) => {
    const notifications = getState().get('notifications');
    const isLoadingMore = !!maxId;

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

    dispatch(expandNotificationsRequest(isLoadingMore));

    api(getState).get('/api/v1/notifications', { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(importFetchedAccounts(response.data.map(item => item.account)));
      dispatch(importFetchedStatuses(response.data.map(item => item.status).filter(status => !!status)));

      dispatch(expandNotificationsSuccess(response.data, next ? next.uri : null, isLoadingMore));
      fetchRelatedRelationships(dispatch, response.data);
      done();
    }).catch(error => {
      dispatch(expandNotificationsFail(error, isLoadingMore));
      done();
    });
  };
};

export function expandNotificationsRequest(isLoadingMore) {
  return {
    type: NOTIFICATIONS_EXPAND_REQUEST,
    skipLoading: !isLoadingMore,
  };
};

export function expandNotificationsSuccess(notifications, next, isLoadingMore) {
  return {
    type: NOTIFICATIONS_EXPAND_SUCCESS,
    notifications,
    next,
    skipLoading: !isLoadingMore,
  };
};

export function expandNotificationsFail(error, isLoadingMore) {
  return {
    type: NOTIFICATIONS_EXPAND_FAIL,
    error,
    skipLoading: !isLoadingMore,
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
