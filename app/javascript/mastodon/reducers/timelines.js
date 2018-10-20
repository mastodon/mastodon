import {
  TIMELINE_UPDATE,
  TIMELINE_DELETE,
  TIMELINE_CLEAR,
  TIMELINE_EXPAND_SUCCESS,
  TIMELINE_EXPAND_REQUEST,
  TIMELINE_EXPAND_FAIL,
  TIMELINE_SCROLL_TOP,
  TIMELINE_DISCONNECT,
} from '../actions/timelines';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
} from '../actions/accounts';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';
import compareId from '../compare_id';

const initialState = ImmutableMap();

const initialTimeline = ImmutableMap({
  unread: 0,
  top: true,
  isLoading: false,
  hasMore: true,
  items: ImmutableList(),
});

const expandNormalizedTimeline = (state, timeline, statuses, next, isPartial) => {
  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    mMap.set('isLoading', false);
    if (!next) mMap.set('hasMore', false);

    if (!statuses.isEmpty()) {
      mMap.update('items', ImmutableList(), oldIds => {
        const newIds = statuses.map(status => status.get('id'));

        if (timeline.indexOf(':pinned') !== -1) {
          return newIds;
        }

        const lastIndex = oldIds.findLastIndex(id => id !== null && compareId(id, newIds.last()) >= 0) + 1;
        const firstIndex = oldIds.take(lastIndex).findLastIndex(id => id !== null && compareId(id, newIds.first()) > 0);

        if (firstIndex < 0) {
          return (isPartial ? newIds.unshift(null) : newIds).concat(oldIds.skip(lastIndex));
        }

        return oldIds.take(firstIndex + 1).concat(
          isPartial && oldIds.get(firstIndex) !== null ? newIds.unshift(null) : newIds,
          oldIds.skip(lastIndex)
        );
      });
    }
  }));
};

const updateTimeline = (state, timeline, status) => {
  const top        = state.getIn([timeline, 'top']);
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

const deleteStatus = (state, id, accountId, references) => {
  state.keySeq().forEach(timeline => {
    state = state.updateIn([timeline, 'items'], list => list.filterNot(item => item === id));
  });

  // Remove reblogs of deleted status
  references.forEach(ref => {
    state = deleteStatus(state, ref[0], ref[1], []);
  });

  return state;
};

const clearTimeline = (state, timeline) => {
  return state.updateIn([timeline, 'items'], list => list.clear());
};

const filterTimelines = (state, relationship, statuses) => {
  let references;

  statuses.forEach(status => {
    if (status.get('account') !== relationship.id) {
      return;
    }

    references = statuses.filter(item => item.get('reblog') === status.get('id')).map(item => [item.get('id'), item.get('account')]);
    state      = deleteStatus(state, status.get('id'), status.get('account'), references);
  });

  return state;
};

const filterTimeline = (timeline, state, relationship, statuses) =>
  state.updateIn([timeline, 'items'], ImmutableList(), list =>
    list.filterNot(statusId =>
      statuses.getIn([statusId, 'account']) === relationship.id
    ));

const updateTop = (state, timeline, top) => {
  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    if (top) mMap.set('unread', 0);
    mMap.set('top', top);
  }));
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
  case TIMELINE_EXPAND_REQUEST:
    return state.update(action.timeline, initialTimeline, map => map.set('isLoading', true));
  case TIMELINE_EXPAND_FAIL:
    return state.update(action.timeline, initialTimeline, map => map.set('isLoading', false));
  case TIMELINE_EXPAND_SUCCESS:
    return expandNormalizedTimeline(state, action.timeline, fromJS(action.statuses), action.next, action.partial);
  case TIMELINE_UPDATE:
    return updateTimeline(state, action.timeline, fromJS(action.status));
  case TIMELINE_DELETE:
    return deleteStatus(state, action.id, action.accountId, action.references, action.reblogOf);
  case TIMELINE_CLEAR:
    return clearTimeline(state, action.timeline);
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return filterTimelines(state, action.relationship, action.statuses);
  case ACCOUNT_UNFOLLOW_SUCCESS:
    return filterTimeline('home', state, action.relationship, action.statuses);
  case TIMELINE_SCROLL_TOP:
    return updateTop(state, action.timeline, action.top);
  case TIMELINE_DISCONNECT:
    return state.update(
      action.timeline,
      initialTimeline,
      map => map.update(
        'items',
        items => items.first() ? items.unshift(null) : items
      )
    );
  default:
    return state;
  }
};
