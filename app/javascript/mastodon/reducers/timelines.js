/// this file is definitely important for pagination
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
} from '../actions/timelines';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
} from '../actions/accounts';
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

  console.log('Expanding timeline:', timeline);
  console.log('Statuses:', statuses.toJS());
  console.log('Next:', next);
  console.log('Is Partial:', isPartial);
  console.log('Is Loading Recent:', isLoadingRecent);
  console.log('Use Pending Items:', usePendingItems);

  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    mMap.set('isLoading', false);
    mMap.set('isPartial', isPartial);

    if (!next && !isLoadingRecent) {
      console.log('No more items to load');
      mMap.set('hasMore', false);
    }

    if (timeline.endsWith(':pinned')) {
      console.log('Updating pinned items');
      mMap.set('items', statuses.map(status => status.get('id')));
    } else if (!statuses.isEmpty()) {
      console.log('Updating timeline items');
      usePendingItems = isLoadingRecent && (usePendingItems || !mMap.get('pendingItems').isEmpty());

      mMap.update(usePendingItems ? 'pendingItems' : 'items', ImmutableList(), oldIds => {
        const newIds = statuses.map(status => status.get('id'));
        console.log('Old IDs:', oldIds.toJS());
        console.log('New IDs:', newIds.toJS());

        // Append newIds to the end of oldIds, ensuring no duplicates
        return oldIds.concat(newIds.filter(id => !oldIds.includes(id)));
      });
    }
  }));
};

const updateTimeline = (state, timeline, status, usePendingItems) => {
  const top = state.getIn([timeline, 'top']);

  if (usePendingItems || !state.getIn([timeline, 'pendingItems']).isEmpty()) {
    if (state.getIn([timeline, 'pendingItems'], ImmutableList()).includes(status.get('id')) || state.getIn([timeline, 'items'], ImmutableList()).includes(status.get('id'))) {
      return state;
    }

    return state.update(timeline, initialTimeline, map => map.update('pendingItems', list => list.unshift(status.get('id'))).update('unread', unread => unread + 1));
  }

  const ids        = state.getIn([timeline, 'items'], ImmutableList());
  const includesId = ids.includes(status.get('id'));
  const unread     = state.getIn([timeline, 'unread'], 0);

  if (includesId) {
    return state;
  }

  let newIds = ids;

  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    if (!top) mMap.set('unread', unread + 1);
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
    return updateTimeline(state, action.timeline, fromJS(action.status), action.usePendingItems);
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
}
