import {
  NOTIFICATIONS_MOUNT,
  NOTIFICATIONS_UNMOUNT,
  NOTIFICATIONS_SET_VISIBILITY,
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_EXPAND_SUCCESS,
  NOTIFICATIONS_EXPAND_REQUEST,
  NOTIFICATIONS_EXPAND_FAIL,
  NOTIFICATIONS_FILTER_SET,
  NOTIFICATIONS_CLEAR,
  NOTIFICATIONS_SCROLL_TOP,
  NOTIFICATIONS_LOAD_PENDING,
  NOTIFICATIONS_DELETE_MARKED_REQUEST,
  NOTIFICATIONS_DELETE_MARKED_SUCCESS,
  NOTIFICATION_MARK_FOR_DELETE,
  NOTIFICATIONS_DELETE_MARKED_FAIL,
  NOTIFICATIONS_ENTER_CLEARING_MODE,
  NOTIFICATIONS_MARK_ALL_FOR_DELETE,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_SET_BROWSER_SUPPORT,
  NOTIFICATIONS_SET_BROWSER_PERMISSION,
  NOTIFICATIONS_DISMISS_BROWSER_PERMISSION,
} from 'flavours/glitch/actions/notifications';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
  FOLLOW_REQUEST_AUTHORIZE_SUCCESS,
  FOLLOW_REQUEST_REJECT_SUCCESS,
} from 'flavours/glitch/actions/accounts';
import {
  MARKERS_FETCH_SUCCESS,
} from 'flavours/glitch/actions/markers';
import { DOMAIN_BLOCK_SUCCESS } from 'flavours/glitch/actions/domain_blocks';
import { TIMELINE_DELETE, TIMELINE_DISCONNECT } from 'flavours/glitch/actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import compareId from 'flavours/glitch/util/compare_id';

const initialState = ImmutableMap({
  pendingItems: ImmutableList(),
  items: ImmutableList(),
  hasMore: true,
  top: false,
  mounted: 0,
  unread: 0,
  lastReadId: '0',
  readMarkerId: '0',
  isLoading: false,
  cleaningMode: false,
  isTabVisible: true,
  browserSupport: false,
  browserPermission: 'default',
  // notification removal mark of new notifs loaded whilst cleaningMode is true.
  markNewForDelete: false,
});

const notificationToMap = (state, notification) => ImmutableMap({
  id: notification.id,
  type: notification.type,
  account: notification.account.id,
  markedForDelete: state.get('markNewForDelete'),
  status: notification.status ? notification.status.id : null,
});

const normalizeNotification = (state, notification, usePendingItems) => {
  const top = state.get('top');

  if (usePendingItems || !state.get('pendingItems').isEmpty()) {
    return state.update('pendingItems', list => list.unshift(notificationToMap(state, notification))).update('unread', unread => unread + 1);
  }

  if (shouldCountUnreadNotifications(state)) {
    state = state.update('unread', unread => unread + 1);
  } else {
    state = state.set('lastReadId', notification.id);
  }

  return state.update('items', list => {
    if (top && list.size > 40) {
      list = list.take(20);
    }

    return list.unshift(notificationToMap(state, notification));
  });
};

const expandNormalizedNotifications = (state, notifications, next, isLoadingRecent, usePendingItems) => {
  const lastReadId = state.get('lastReadId');
  let items = ImmutableList();

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(state, n));
  });

  return state.withMutations(mutable => {
    if (!items.isEmpty()) {
      usePendingItems = isLoadingRecent && (usePendingItems || !mutable.get('pendingItems').isEmpty());

      mutable.update(usePendingItems ? 'pendingItems' : 'items', list => {
        const lastIndex = 1 + list.findLastIndex(
          item => item !== null && (compareId(item.get('id'), items.last().get('id')) > 0 || item.get('id') === items.last().get('id')),
        );

        const firstIndex = 1 + list.take(lastIndex).findLastIndex(
          item => item !== null && compareId(item.get('id'), items.first().get('id')) > 0,
        );

        return list.take(firstIndex).concat(items, list.skip(lastIndex));
      });
    }

    if (!next) {
      mutable.set('hasMore', false);
    }

    if (shouldCountUnreadNotifications(state)) {
      mutable.update('unread', unread => unread + items.count(item => compareId(item.get('id'), lastReadId) > 0));
    } else {
      const mostRecent = items.find(item => item !== null);
      if (mostRecent && compareId(lastReadId, mostRecent.get('id')) < 0) {
        mutable.set('lastReadId', mostRecent.get('id'));
      }
    }

    mutable.set('isLoading', false);
  });
};

const filterNotifications = (state, accountIds, type) => {
  const helper = list => list.filterNot(item => item !== null && accountIds.includes(item.get('account')) && (type === undefined || type === item.get('type')));
  return state.update('items', helper).update('pendingItems', helper);
};

const clearUnread = (state) => {
  state = state.set('unread', state.get('pendingItems').size);
  const lastNotification = state.get('items').find(item => item !== null);
  return state.set('lastReadId', lastNotification ? lastNotification.get('id') : '0');
};

const updateTop = (state, top) => {
  state = state.set('top', top);

  if (!shouldCountUnreadNotifications(state)) {
    state = clearUnread(state);
  }

  return state;
};

const deleteByStatus = (state, statusId) => {
  const lastReadId = state.get('lastReadId');

  if (shouldCountUnreadNotifications(state)) {
    const deletedUnread = state.get('items').filter(item => item !== null && item.get('status') === statusId && compareId(item.get('id'), lastReadId) > 0);
    state = state.update('unread', unread => unread - deletedUnread.size);
  }

  const helper = list => list.filterNot(item => item !== null && item.get('status') === statusId);
  const deletedUnread = state.get('pendingItems').filter(item => item !== null && item.get('status') === statusId && compareId(item.get('id'), lastReadId) > 0);
  state = state.update('unread', unread => unread - deletedUnread.size);
  return state.update('items', helper).update('pendingItems', helper);
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

const markAllForDelete = (state, yes) => {
  return state.update('items', list => list.map(item => {
    if(yes !== null) {
      return item.set('markedForDelete', yes);
    } else {
      return item.set('markedForDelete', !item.get('markedForDelete'));
    }
  }));
};

const unmarkAllForDelete = (state) => {
  return state.update('items', list => list.map(item => item.set('markedForDelete', false)));
};

const deleteMarkedNotifs = (state) => {
  return state.update('items', list => list.filterNot(item => item.get('markedForDelete')));
};

const updateMounted = (state) => {
  state = state.update('mounted', count => count + 1);
  if (!shouldCountUnreadNotifications(state, state.get('mounted') === 1)) {
    state = state.set('readMarkerId', state.get('lastReadId'));
    state = clearUnread(state);
  }
  return state;
};

const updateVisibility = (state, visibility) => {
  state = state.set('isTabVisible', visibility);
  if (!shouldCountUnreadNotifications(state)) {
    state = state.set('readMarkerId', state.get('lastReadId'));
    state = clearUnread(state);
  }
  return state;
};

const shouldCountUnreadNotifications = (state, ignoreScroll = false) => {
  const isTabVisible   = state.get('isTabVisible');
  const isOnTop        = state.get('top');
  const isMounted      = state.get('mounted') > 0;
  const lastReadId     = state.get('lastReadId');
  const lastItem       = state.get('items').findLast(item => item !== null);
  const lastItemReached = !state.get('hasMore') || lastReadId === '0' || (lastItem && compareId(lastItem.get('id'), lastReadId) <= 0);

  return !(isTabVisible && (ignoreScroll || isOnTop) && isMounted && lastItemReached);
};

const recountUnread = (state, last_read_id) => {
  return state.withMutations(mutable => {
    if (compareId(last_read_id, mutable.get('lastReadId')) > 0) {
      mutable.set('lastReadId', last_read_id);
    }

    if (compareId(last_read_id, mutable.get('readMarkerId')) > 0) {
      mutable.set('readMarkerId', last_read_id);
    }

    if (state.get('unread') > 0 || shouldCountUnreadNotifications(state)) {
      mutable.set('unread', mutable.get('pendingItems').count(item => item !== null) + mutable.get('items').count(item => item && compareId(item.get('id'), last_read_id) > 0));
    }
  });
};

export default function notifications(state = initialState, action) {
  let st;

  switch(action.type) {
  case MARKERS_FETCH_SUCCESS:
    return action.markers.notifications ? recountUnread(state, action.markers.notifications.last_read_id) : state;
  case NOTIFICATIONS_MOUNT:
    return updateMounted(state);
  case NOTIFICATIONS_UNMOUNT:
    return state.update('mounted', count => count - 1);
  case NOTIFICATIONS_SET_VISIBILITY:
    return updateVisibility(state, action.visibility);
  case NOTIFICATIONS_LOAD_PENDING:
    return state.update('items', list => state.get('pendingItems').concat(list.take(40))).set('pendingItems', ImmutableList()).set('unread', 0);
  case NOTIFICATIONS_EXPAND_REQUEST:
  case NOTIFICATIONS_DELETE_MARKED_REQUEST:
    return state.set('isLoading', true);
  case NOTIFICATIONS_DELETE_MARKED_FAIL:
  case NOTIFICATIONS_EXPAND_FAIL:
    return state.set('isLoading', false);
  case NOTIFICATIONS_FILTER_SET:
    return state.set('items', ImmutableList()).set('hasMore', true);
  case NOTIFICATIONS_SCROLL_TOP:
    return updateTop(state, action.top);
  case NOTIFICATIONS_UPDATE:
    return normalizeNotification(state, action.notification, action.usePendingItems);
  case NOTIFICATIONS_EXPAND_SUCCESS:
    return expandNormalizedNotifications(state, action.notifications, action.next, action.isLoadingRecent, action.usePendingItems);
  case ACCOUNT_BLOCK_SUCCESS:
    return filterNotifications(state, [action.relationship.id]);
  case ACCOUNT_MUTE_SUCCESS:
    return action.relationship.muting_notifications ? filterNotifications(state, [action.relationship.id]) : state;
  case DOMAIN_BLOCK_SUCCESS:
    return filterNotifications(state, action.accounts);
  case FOLLOW_REQUEST_AUTHORIZE_SUCCESS:
  case FOLLOW_REQUEST_REJECT_SUCCESS:
    return filterNotifications(state, [action.id], 'follow_request');
  case ACCOUNT_MUTE_SUCCESS:
    return action.relationship.muting_notifications ? filterNotifications(state, [action.relationship.id]) : state;
  case NOTIFICATIONS_CLEAR:
    return state.set('items', ImmutableList()).set('pendingItems', ImmutableList()).set('hasMore', false);
  case TIMELINE_DELETE:
    return deleteByStatus(state, action.id);
  case TIMELINE_DISCONNECT:
    return action.timeline === 'home' ?
      state.update(action.usePendingItems ? 'pendingItems' : 'items', items => items.first() ? items.unshift(null) : items) :
      state;
  case NOTIFICATIONS_SET_BROWSER_SUPPORT:
    return state.set('browserSupport', action.value);
  case NOTIFICATIONS_SET_BROWSER_PERMISSION:
    return state.set('browserPermission', action.value);
  case NOTIFICATIONS_DISMISS_BROWSER_PERMISSION:
    return state.set('browserPermission', 'denied');

  case NOTIFICATION_MARK_FOR_DELETE:
    return markForDelete(state, action.id, action.yes);

  case NOTIFICATIONS_DELETE_MARKED_SUCCESS:
    return deleteMarkedNotifs(state).set('isLoading', false);

  case NOTIFICATIONS_ENTER_CLEARING_MODE:
    st = state.set('cleaningMode', action.yes);
    if (!action.yes) {
      return unmarkAllForDelete(st).set('markNewForDelete', false);
    } else {
      return st;
    }

  case NOTIFICATIONS_MARK_ALL_FOR_DELETE:
    st = state;
    if (action.yes === null) {
      // Toggle - this is a bit confusing, as it toggles the all-none mode
      //st = st.set('markNewForDelete', !st.get('markNewForDelete'));
    } else {
      st = st.set('markNewForDelete', action.yes);
    }
    return markAllForDelete(st, action.yes);

  case NOTIFICATIONS_MARK_AS_READ:
    const lastNotification = state.get('items').find(item => item !== null);
    return lastNotification ? recountUnread(state, lastNotification.get('id')) : state;

  default:
    return state;
  }
};
