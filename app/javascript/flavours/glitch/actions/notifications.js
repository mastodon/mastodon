import api, { getLinks } from 'flavours/glitch/util/api';
import IntlMessageFormat from 'intl-messageformat';
import { fetchRelationships } from './accounts';
import {
  importFetchedAccount,
  importFetchedAccounts,
  importFetchedStatus,
  importFetchedStatuses,
} from './importer';
import { submitMarkers } from './markers';
import { saveSettings } from './settings';
import { defineMessages } from 'react-intl';
import { List as ImmutableList } from 'immutable';
import { unescapeHTML } from 'flavours/glitch/util/html';
import { getFiltersRegex } from 'flavours/glitch/selectors';
import { usePendingItems as preferPendingItems } from 'flavours/glitch/util/initial_state';
import compareId from 'flavours/glitch/util/compare_id';
import { searchTextFromRawStatus } from 'flavours/glitch/actions/importer/normalizer';

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

export const NOTIFICATIONS_FILTER_SET = 'NOTIFICATIONS_FILTER_SET';

export const NOTIFICATIONS_CLEAR        = 'NOTIFICATIONS_CLEAR';
export const NOTIFICATIONS_SCROLL_TOP   = 'NOTIFICATIONS_SCROLL_TOP';
export const NOTIFICATIONS_LOAD_PENDING = 'NOTIFICATIONS_LOAD_PENDING';

export const NOTIFICATIONS_MOUNT   = 'NOTIFICATIONS_MOUNT';
export const NOTIFICATIONS_UNMOUNT = 'NOTIFICATIONS_UNMOUNT';

export const NOTIFICATIONS_SET_VISIBILITY = 'NOTIFICATIONS_SET_VISIBILITY';

defineMessages({
  mention: { id: 'notification.mention', defaultMessage: '{name} mentioned you' },
});

const fetchRelatedRelationships = (dispatch, notifications) => {
  const accountIds = notifications.filter(item => item.type === 'follow').map(item => item.account.id);

  if (accountIds > 0) {
    dispatch(fetchRelationships(accountIds));
  }
};

export const loadPending = () => ({
  type: NOTIFICATIONS_LOAD_PENDING,
});

export function updateNotifications(notification, intlMessages, intlLocale) {
  return (dispatch, getState) => {
    const showInColumn = getState().getIn(['settings', 'notifications', 'shows', notification.type], true);
    const showAlert    = getState().getIn(['settings', 'notifications', 'alerts', notification.type], true);
    const playSound    = getState().getIn(['settings', 'notifications', 'sounds', notification.type], true);
    const filters      = getFiltersRegex(getState(), { contextType: 'notifications' });

    let filtered = false;

    if (notification.type === 'mention') {
      const dropRegex   = filters[0];
      const regex       = filters[1];
      const searchIndex = searchTextFromRawStatus(notification.status);

      if (dropRegex && dropRegex.test(searchIndex)) {
        return;
      }

      filtered = regex && regex.test(searchIndex);
    }

    dispatch(submitMarkers());

    if (showInColumn) {
      dispatch(importFetchedAccount(notification.account));

      if (notification.status) {
        dispatch(importFetchedStatus(notification.status));
      }

      dispatch({
        type: NOTIFICATIONS_UPDATE,
        notification,
        usePendingItems: preferPendingItems,
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


const excludeTypesFromFilter = filter => {
  const allTypes = ImmutableList(['follow', 'follow_request', 'favourite', 'reblog', 'mention', 'poll']);
  return allTypes.filterNot(item => item === filter).toJS();
};

const noOp = () => {};

export function expandNotifications({ maxId } = {}, done = noOp) {
  return (dispatch, getState) => {
    const activeFilter = getState().getIn(['settings', 'notifications', 'quickFilter', 'active']);
    const notifications = getState().get('notifications');
    const isLoadingMore = !!maxId;

    if (notifications.get('isLoading')) {
      done();
      return;
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

    api(getState).get('/api/v1/notifications', { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(importFetchedAccounts(response.data.map(item => item.account)));
      dispatch(importFetchedStatuses(response.data.map(item => item.status).filter(status => !!status)));

      dispatch(expandNotificationsSuccess(response.data, next ? next.uri : null, isLoadingMore, isLoadingRecent, isLoadingRecent && preferPendingItems));
      fetchRelatedRelationships(dispatch, response.data);
      dispatch(submitMarkers());
    }).catch(error => {
      dispatch(expandNotificationsFail(error, isLoadingMore));
    }).finally(() => {
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

export function expandNotificationsSuccess(notifications, next, isLoadingMore, isLoadingRecent, usePendingItems) {
  return {
    type: NOTIFICATIONS_EXPAND_SUCCESS,
    notifications,
    next,
    isLoadingRecent: isLoadingRecent,
    usePendingItems,
    skipLoading: !isLoadingMore,
  };
};

export function expandNotificationsFail(error, isLoadingMore) {
  return {
    type: NOTIFICATIONS_EXPAND_FAIL,
    error,
    skipLoading: !isLoadingMore,
    skipAlert: !isLoadingMore,
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

export function mountNotifications() {
  return {
    type: NOTIFICATIONS_MOUNT,
  };
};

export function unmountNotifications() {
  return {
    type: NOTIFICATIONS_UNMOUNT,
  };
};

export function notificationsSetVisibility(visibility) {
  return {
    type: NOTIFICATIONS_SET_VISIBILITY,
    visibility: visibility,
  };
};

export function setFilter (filterType) {
  return dispatch => {
    dispatch({
      type: NOTIFICATIONS_FILTER_SET,
      path: ['notifications', 'quickFilter', 'active'],
      value: filterType,
    });
    dispatch(expandNotifications());
    dispatch(saveSettings());
  };
};
