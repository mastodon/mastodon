import { fromJS, Map as ImmutableMap, List as ImmutableList } from 'immutable';

import { blockDomainSuccess } from 'flavours/glitch/actions/domain_blocks';

import {
  authorizeFollowRequestSuccess,
  blockAccountSuccess,
  muteAccountSuccess,
  rejectFollowRequestSuccess,
} from '../actions/accounts';
import {
  fetchMarkers,
} from '../actions/markers';
import {
  NOTIFICATIONS_MOUNT,
  NOTIFICATIONS_UNMOUNT,
  NOTIFICATIONS_SET_VISIBILITY,
  notificationsUpdate,
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
} from '../actions/notifications';
import { TIMELINE_DELETE, TIMELINE_DISCONNECT } from '../actions/timelines';
import { compareId } from '../compare_id';

const initialState = ImmutableMap({
  pendingItems: ImmutableList(),
  items: ImmutableList(),
  hasMore: true,
  top: false,
  mounted: 0,
  unread: 0,
  lastReadId: '0',
  readMarkerId: '0',
  isLoading: 0,
  cleaningMode: false,
  isTabVisible: true,
  browserSupport: false,
  browserPermission: 'default',
  // notification removal mark of new notifs loaded whilst cleaningMode is true.
  markNewForDelete: false,
});

export const notificationToMap = (notification, markForDelete = false) => ImmutableMap({
  id: notification.id,
  type: notification.type,
  account: notification.account.id,
  markedForDelete: markForDelete,
  status: notification.status ? notification.status.id : null,
  report: notification.report ? fromJS(notification.report) : null,
  event: notification.event ? fromJS(notification.event) : null,
  moderation_warning: notification.moderation_warning ? fromJS(notification.moderation_warning) : null,
});

const normalizeNotification = (state, notification, usePendingItems) => {
  const markNewForDelete = state.get('markNewForDelete');
  const top = state.get('top');

  // Under currently unknown conditions, the client may receive duplicates from the server
  if (state.get('pendingItems').some((item) => item?.get('id') === notification.id) || state.get('items').some((item) => item?.get('id') === notification.id)) {
    return state;
  }

  if (usePendingItems || !state.get('pendingItems').isEmpty()) {
    return state.update('pendingItems', list => list.unshift(notificationToMap(notification, markNewForDelete))).update('unread', unread => unread + 1);
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

    return list.unshift(notificationToMap(notification, markNewForDelete));
  });
};

const expandNormalizedNotifications = (state, notifications, next, isLoadingMore, isLoadingRecent, usePendingItems) => {
  // This method is pretty tricky because:
  // - existing notifications might be out of order
  // - the existing notifications may have gaps, most often explicitly noted with a `null` item
  // - ideally, we don't want it to reorder existing items
  // - `notifications` may include items that are already included
  // - this function can be called either to fill in a gap, or load newer items

  const markNewForDelete = state.get('markNewForDelete');
  const lastReadId = state.get('lastReadId');
  const newItems = ImmutableList(notifications.map((notification) => notificationToMap(notification, markNewForDelete)));

  return state.withMutations(mutable => {
    if (!newItems.isEmpty()) {
      usePendingItems = isLoadingRecent && (usePendingItems || !mutable.get('pendingItems').isEmpty());

      mutable.update(usePendingItems ? 'pendingItems' : 'items', oldItems => {
        // If called to poll *new* notifications, we just need to add them on top without duplicates
        if (isLoadingRecent) {
          const idsToCheck = oldItems.map(item => item?.get('id')).toSet();
          const insertedItems = newItems.filterNot(item => idsToCheck.includes(item.get('id')));
          return insertedItems.concat(oldItems);
        }

        // If called to expand more (presumably older than any known to the WebUI), we just have to
        // add them to the bottom without duplicates
        if (isLoadingMore) {
          const idsToCheck = oldItems.map(item => item?.get('id')).toSet();
          const insertedItems = newItems.filterNot(item => idsToCheck.includes(item.get('id')));
          return oldItems.concat(insertedItems);
        }

        // Now this gets tricky, as we don't necessarily know for sure where the gap to fill is,
        // and some items in the timeline may not be properly ordered.

        // However, we know that `newItems.last()` is the oldest item that was requested and that
        // there is no “hole” between `newItems.last()` and `newItems.first()`.

        // First, find the furthest (if properly sorted, oldest) item in the notifications that is
        // newer than the oldest fetched one, as it's most likely that it delimits the gap.
        // Start the gap *after* that item.
        const lastIndex = oldItems.findLastIndex(item => item !== null && compareId(item.get('id'), newItems.last().get('id')) >= 0) + 1;

        // Then, try to find the furthest (if properly sorted, oldest) item in the notifications that
        // is newer than the most recent fetched one, as it delimits a section comprised of only
        // items older or within `newItems` (or that were deleted from the server, so should be removed
        // anyway).
        // Stop the gap *after* that item.
        const firstIndex = oldItems.take(lastIndex).findLastIndex(item => item !== null && compareId(item.get('id'), newItems.first().get('id')) > 0) + 1;

        // At this point:
        // - no `oldItems` after `firstIndex` is newer than any of the `newItems`
        // - all `oldItems` after `lastIndex` are older than every of the `newItems`
        // - it is possible for items in the replaced slice to be older than every `newItems`
        // - it is possible for items before `firstIndex` to be in the `newItems` range
        // Therefore:
        // - to avoid losing items, items from the replaced slice that are older than `newItems`
        //   should be added in the back.
        // - to avoid duplicates, `newItems` should be checked the first `firstIndex` items of
        //   `oldItems`
        const idsToCheck = oldItems.take(firstIndex).map(item => item?.get('id')).toSet();
        const insertedItems = newItems.filterNot(item => idsToCheck.includes(item.get('id')));
        const olderItems = oldItems.slice(firstIndex, lastIndex).filter(item => item !== null && compareId(item.get('id'), newItems.last().get('id')) < 0);

        return oldItems.take(firstIndex).concat(
          insertedItems,
          olderItems,
          oldItems.skip(lastIndex),
        );
      });
    }

    if (!next) {
      mutable.set('hasMore', false);
    }

    if (shouldCountUnreadNotifications(state)) {
      mutable.set('unread', mutable.get('pendingItems').count(item => item !== null) + mutable.get('items').count(item => item && compareId(item.get('id'), lastReadId) > 0));
    } else {
      const mostRecent = newItems.find(item => item !== null);
      if (mostRecent && compareId(lastReadId, mostRecent.get('id')) < 0) {
        mutable.set('lastReadId', mostRecent.get('id'));
      }
    }

    mutable.update('isLoading', (nbLoading) => nbLoading - 1);
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
    if (item === null) {
      return null;
    } else if(item.get('id') === notificationId) {
      return item.set('markedForDelete', yes);
    } else {
      return item;
    }
  }));
};

const markAllForDelete = (state, yes) => {
  return state.update('items', list => list.map(item => {
    if (item === null) {
      return null;
    } else if(yes !== null) {
      return item.set('markedForDelete', yes);
    } else {
      return item.set('markedForDelete', !item.get('markedForDelete'));
    }
  }));
};

const unmarkAllForDelete = (state) => {
  return state.update('items', list => list.map(item => item === null ? item : item.set('markedForDelete', false)));
};

const deleteMarkedNotifs = (state) => {
  return state.update('items', list => list.filterNot(item => item === null ? item : item.get('markedForDelete')));
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
  case fetchMarkers.fulfilled.type:
    return action.payload.markers.notifications ? recountUnread(state, action.payload.markers.notifications.last_read_id) : state;
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
    return state.update('isLoading', (nbLoading) => nbLoading + 1);
  case NOTIFICATIONS_DELETE_MARKED_FAIL:
  case NOTIFICATIONS_EXPAND_FAIL:
    return state.update('isLoading', (nbLoading) => nbLoading - 1);
  case NOTIFICATIONS_FILTER_SET:
    return state.set('items', ImmutableList()).set('pendingItems', ImmutableList()).set('hasMore', true);
  case NOTIFICATIONS_SCROLL_TOP:
    return updateTop(state, action.top);
  case notificationsUpdate.type:
    return normalizeNotification(state, action.payload.notification, action.payload.usePendingItems);
  case NOTIFICATIONS_EXPAND_SUCCESS:
    return expandNormalizedNotifications(state, action.notifications, action.next, action.isLoadingMore, action.isLoadingRecent, action.usePendingItems);
  case blockAccountSuccess.type:
    return filterNotifications(state, [action.payload.relationship.id]);
  case muteAccountSuccess.type:
    return action.payload.relationship.muting_notifications ? filterNotifications(state, [action.payload.relationship.id]) : state;
  case blockDomainSuccess.type:
    return filterNotifications(state, action.payload.accounts);
  case authorizeFollowRequestSuccess.type:
  case rejectFollowRequestSuccess.type:
    return filterNotifications(state, [action.payload.id], 'follow_request');
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

  case NOTIFICATION_MARK_FOR_DELETE:
    return markForDelete(state, action.id, action.yes);

  case NOTIFICATIONS_DELETE_MARKED_SUCCESS:
    return deleteMarkedNotifs(state).update('isLoading', (nbLoading) => nbLoading - 1);

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
}
