import {
  TIMELINE_UPDATE,
  TIMELINE_DELETE,
  TIMELINE_CLEAR,
  TIMELINE_EXPAND_SUCCESS,
  TIMELINE_EXPAND_REQUEST,
  TIMELINE_EXPAND_FAIL,
  TIMELINE_SCROLL_TOP,
  TIMELINE_CONNECT,
  TIMELINE_DISCONNECT,
  TIMELINE_LOAD_PENDING,
  TIMELINE_MARK_AS_PARTIAL,
} from 'flavours/glitch/actions/timelines';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
} from 'flavours/glitch/actions/accounts';
import { Map as ImmutableMap, List as ImmutableList, OrderedSet as ImmutableOrderedSet, fromJS } from 'immutable';
import compareId from '../compare_id';

const initialState = ImmutableMap();

const initialTimeline = ImmutableMap({
  unread: 0,
  online: false,
  top: true,
  isLoading: false,
  hasMore: true,
  pendingItems: ImmutableList(),
  items: ImmutableList(),
});

const expandNormalizedTimeline = (state, timeline, statuses, next, isPartial, isLoadingRecent, usePendingItems) => {
  // This method is pretty tricky because:
  // - existing items in the timeline might be out of order
  // - the existing timeline may have gaps, most often explicitly noted with a `null` item
  // - ideally, we don't want it to reorder existing items of the timeline
  // - `statuses` may include items that are already included in the timeline
  // - this function can be called either to fill in a gap, or load newer items

  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    mMap.set('isLoading', false);
    mMap.set('isPartial', isPartial);

    if (!next && !isLoadingRecent) mMap.set('hasMore', false);

    if (timeline.endsWith(':pinned')) {
      mMap.set('items', statuses.map(status => status.get('id')));
    } else if (!statuses.isEmpty()) {
      usePendingItems = isLoadingRecent && (usePendingItems || !mMap.get('pendingItems').isEmpty());

      mMap.update(usePendingItems ? 'pendingItems' : 'items', ImmutableList(), oldIds => {
        const newIds = statuses.map(status => status.get('id'));

        // Now this gets tricky, as we don't necessarily know for sure where the gap to fill is
        // and some items in the timeline may not be properly ordered.

        // However, we know that `newIds.last()` is the oldest item that was requested and that
        // there is no “hole” between `newIds.last()` and `newIds.first()`.

        // First, find the furthest (if properly sorted, oldest) item in the timeline that is
        // newer than the oldest fetched one, as it's most likely that it delimits the gap.
        // Start the gap *after* that item.
        const lastIndex = oldIds.findLastIndex(id => id !== null && compareId(id, newIds.last()) >= 0) + 1;

        // Then, try to find the furthest (if properly sorted, oldest) item in the timeline that
        // is newer than the most recent fetched one, as it delimits a section comprised of only
        // items older or within `newIds` (or that were deleted from the server, so should be removed
        // anyway).
        // Stop the gap *after* that item.
        const firstIndex = oldIds.take(lastIndex).findLastIndex(id => id !== null && compareId(id, newIds.first()) > 0) + 1;

        let insertedIds = ImmutableOrderedSet(newIds).withMutations(insertedIds => {
          // It is possible, though unlikely, that the slice we are replacing contains items older
          // than the elements we got from the API. Get them and add them back at the back of the
          // slice.
          const olderIds = oldIds.slice(firstIndex, lastIndex).filter(id => id !== null && compareId(id, newIds.last()) < 0);
          insertedIds.union(olderIds);

          // Make sure we aren't inserting duplicates
          insertedIds.subtract(oldIds.take(firstIndex), oldIds.skip(lastIndex));
        }).toList();

        // Finally, insert a gap marker if the data is marked as partial by the server
        if (isPartial && (firstIndex === 0 || oldIds.get(firstIndex - 1) !== null)) {
          insertedIds = insertedIds.unshift(null);
        }

        return oldIds.take(firstIndex).concat(
          insertedIds,
          oldIds.skip(lastIndex),
        );
      });
    }
  }));
};

const updateTimeline = (state, timeline, status, usePendingItems, filtered) => {
  const top = state.getIn([timeline, 'top']);

  if (usePendingItems || !state.getIn([timeline, 'pendingItems']).isEmpty()) {
    if (state.getIn([timeline, 'pendingItems'], ImmutableList()).includes(status.get('id')) || state.getIn([timeline, 'items'], ImmutableList()).includes(status.get('id'))) {
      return state;
    }

    state = state.update(timeline, initialTimeline, map => map.update('pendingItems', list => list.unshift(status.get('id'))));

    if (!filtered) {
      state = state.updateIn([timeline, 'unread'], unread => unread + 1);
    }

    return state;
  }

  const ids        = state.getIn([timeline, 'items'], ImmutableList());
  const includesId = ids.includes(status.get('id'));
  const unread     = state.getIn([timeline, 'unread'], 0);

  if (includesId) {
    return state;
  }

  let newIds = ids;

  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    if (!top && !filtered) mMap.set('unread', unread + 1);
    if (top && ids.size > 40) newIds = newIds.take(20);
    mMap.set('items', newIds.unshift(status.get('id')));
  }));
};

const deleteStatus = (state, id, references, exclude_account = null) => {
  state.keySeq().forEach(timeline => {
    if (exclude_account === null || (timeline !== `account:${exclude_account}` && !timeline.startsWith(`account:${exclude_account}:`))) {
      const helper = list => list.filterNot(item => item === id);
      state = state.updateIn([timeline, 'items'], helper).updateIn([timeline, 'pendingItems'], helper);
    }
  });

  // Remove reblogs of deleted status
  references.forEach(ref => {
    state = deleteStatus(state, ref, [], exclude_account);
  });

  return state;
};

const clearTimeline = (state, timeline) => {
  return state.set(timeline, initialTimeline);
};

const filterTimelines = (state, relationship, statuses) => {
  let references;

  statuses.forEach(status => {
    if (status.get('account') !== relationship.id) {
      return;
    }

    references = statuses.filter(item => item.get('reblog') === status.get('id')).map(item => item.get('id'));
    state      = deleteStatus(state, status.get('id'), references, relationship.id);
  });

  return state;
};

const filterTimeline = (timeline, state, relationship, statuses) => {
  const helper = list => list.filterNot(statusId => statuses.getIn([statusId, 'account']) === relationship.id);
  return state.updateIn([timeline, 'items'], ImmutableList(), helper).updateIn([timeline, 'pendingItems'], ImmutableList(), helper);
};

const updateTop = (state, timeline, top) => {
  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    if (top) mMap.set('unread', mMap.get('pendingItems').size);
    mMap.set('top', top);
  }));
};

const reconnectTimeline = (state, usePendingItems) => {
  if (state.get('online')) {
    return state;
  }

  return state.withMutations(mMap => {
    mMap.update(usePendingItems ? 'pendingItems' : 'items', items => items.first() ? items.unshift(null) : items);
    mMap.set('online', true);
  });
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
  case TIMELINE_LOAD_PENDING:
    return state.update(action.timeline, initialTimeline, map =>
      map.update('items', list => map.get('pendingItems').concat(list.take(40))).set('pendingItems', ImmutableList()).set('unread', 0));
  case TIMELINE_EXPAND_REQUEST:
    return state.update(action.timeline, initialTimeline, map => map.set('isLoading', true));
  case TIMELINE_EXPAND_FAIL:
    return state.update(action.timeline, initialTimeline, map => map.set('isLoading', false));
  case TIMELINE_EXPAND_SUCCESS:
    return expandNormalizedTimeline(state, action.timeline, fromJS(action.statuses), action.next, action.partial, action.isLoadingRecent, action.usePendingItems);
  case TIMELINE_UPDATE:
    return updateTimeline(state, action.timeline, fromJS(action.status), action.usePendingItems, action.filtered);
  case TIMELINE_DELETE:
    return deleteStatus(state, action.id, action.references, action.reblogOf);
  case TIMELINE_CLEAR:
    return clearTimeline(state, action.timeline);
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return filterTimelines(state, action.relationship, action.statuses);
  case ACCOUNT_UNFOLLOW_SUCCESS:
    return filterTimeline('home', state, action.relationship, action.statuses);
  case TIMELINE_SCROLL_TOP:
    return updateTop(state, action.timeline, action.top);
  case TIMELINE_CONNECT:
    return state.update(action.timeline, initialTimeline, map => reconnectTimeline(map, action.usePendingItems));
  case TIMELINE_DISCONNECT:
    return state.update(
      action.timeline,
      initialTimeline,
      map => map.set('online', false).update(action.usePendingItems ? 'pendingItems' : 'items', items => items.first() ? items.unshift(null) : items),
    );
  case TIMELINE_MARK_AS_PARTIAL:
    return state.update(
      action.timeline,
      initialTimeline,
      map => map.set('isPartial', true).set('items', ImmutableList()).set('pendingItems', ImmutableList()).set('unread', 0),
    );
  default:
    return state;
  }
};
