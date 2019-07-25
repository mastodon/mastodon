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
} from 'flavours/glitch/actions/notifications';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
} from 'flavours/glitch/actions/accounts';
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
  isLoading: false,
  cleaningMode: false,
  isTabVisible: true,
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
  if (usePendingItems) {
    return state.update('pendingItems', list => list.unshift(notificationToMap(state, notification)));
  }

  const top = !shouldCountUnreadNotifications(state);

  if (top) {
    state = state.set('lastReadId', notification.id);
  } else {
    state = state.update('unread', unread => unread + 1);
  }

  return state.update('items', list => {
    if (top && list.size > 40) {
      list = list.take(20);
    }

    return list.unshift(notificationToMap(state, notification));
  });
};

const expandNormalizedNotifications = (state, notifications, next, usePendingItems) => {
  const top = !(shouldCountUnreadNotifications(state));
  const lastReadId = state.get('lastReadId');
  let items = ImmutableList();

  notifications.forEach((n, i) => {
    items = items.set(i, notificationToMap(state, n));
  });

  return state.withMutations(mutable => {
    if (!items.isEmpty()) {
      mutable.update(usePendingItems ? 'pendingItems' : 'items', list => {
        const lastIndex = 1 + list.findLastIndex(
          item => item !== null && (compareId(item.get('id'), items.last().get('id')) > 0 || item.get('id') === items.last().get('id'))
        );

        const firstIndex = 1 + list.take(lastIndex).findLastIndex(
          item => item !== null && compareId(item.get('id'), items.first().get('id')) > 0
        );

        return list.take(firstIndex).concat(items, list.skip(lastIndex));
      });
    }

    if (top) {
      if (!items.isEmpty()) {
        mutable.update('lastReadId', id => compareId(id, items.first().get('id')) > 0 ? id : items.first().get('id'));
      }
    } else {
      mutable.update('unread', unread => unread + items.filter(item => compareId(item.get('id'), lastReadId) > 0).size);
    }

    if (!next) {
      mutable.set('hasMore', false);
    }

    mutable.set('isLoading', false);
  });
};

const filterNotifications = (state, accountIds) => {
  const helper = list => list.filterNot(item => item !== null && accountIds.includes(item.get('account')));
  return state.update('items', helper).update('pendingItems', helper);
};

const clearUnread = (state) => {
  state = state.set('unread', 0);
  const lastNotification = state.get('items').find(item => item !== null);
  return state.set('lastReadId', lastNotification ? lastNotification.get('id') : '0');
}

const updateTop = (state, top) => {
  state = state.set('top', top);

  if (!shouldCountUnreadNotifications(state)) {
    state = clearUnread(state);
  }

  return state.set('top', top);
};

const deleteByStatus = (state, statusId) => {
  const top = !(shouldCountUnreadNotifications(state));
  if (!top) {
    const lastReadId = state.get('lastReadId');
    const deletedUnread = state.get('items').filter(item => item !== null && item.get('status') === statusId && compareId(item.get('id'), lastReadId) > 0);
    state = state.update('unread', unread => unread - deletedUnread.size);
  }
  const helper = list => list.filterNot(item => item !== null && item.get('status') === statusId);
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
  if (!shouldCountUnreadNotifications(state)) {
    state = clearUnread(state);
  }
  return state;
};

const updateVisibility = (state, visibility) => {
  state = state.set('isTabVisible', visibility);
  if (!shouldCountUnreadNotifications(state)) {
    state = clearUnread(state);
  }
  return state;
};

const shouldCountUnreadNotifications = (state) => {
  return !(state.get('isTabVisible') && state.get('top') && state.get('mounted') > 0);
};

export default function notifications(state = initialState, action) {
  let st;

  switch(action.type) {
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
    return expandNormalizedNotifications(state, action.notifications, action.next, action.usePendingItems);
  case ACCOUNT_BLOCK_SUCCESS:
    return filterNotifications(state, [action.relationship.id]);
  case ACCOUNT_MUTE_SUCCESS:
    return action.relationship.muting_notifications ? filterNotifications(state, [action.relationship.id]) : state;
  case DOMAIN_BLOCK_SUCCESS:
    return filterNotifications(state, action.accounts);
  case NOTIFICATIONS_CLEAR:
    return state.set('items', ImmutableList()).set('pendingItems', ImmutableList()).set('hasMore', false);
  case TIMELINE_DELETE:
    return deleteByStatus(state, action.id);
  case TIMELINE_DISCONNECT:
    return action.timeline === 'home' ?
      state.update(action.usePendingItems ? 'pendingItems' : 'items', items => items.first() ? items.unshift(null) : items) :
      state;

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

  default:
    return state;
  }
};
