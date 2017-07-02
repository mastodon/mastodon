import {
  TIMELINE_REFRESH_REQUEST,
  TIMELINE_REFRESH_SUCCESS,
  TIMELINE_REFRESH_FAIL,
  TIMELINE_UPDATE,
  TIMELINE_DELETE,
  TIMELINE_EXPAND_SUCCESS,
  TIMELINE_EXPAND_REQUEST,
  TIMELINE_EXPAND_FAIL,
  TIMELINE_SCROLL_TOP,
  TIMELINE_CONNECT,
  TIMELINE_DISCONNECT,
} from '../actions/timelines';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
} from '../actions/accounts';
import Immutable from 'immutable';

const initialState = Immutable.Map();

const initialTimeline = Immutable.Map({
  unread: 0,
  online: false,
  top: true,
  loaded: false,
  isLoading: false,
  next: false,
  items: Immutable.List(),
});

const normalizeTimeline = (state, timeline, statuses, next) => {
  const ids       = Immutable.List(statuses.map(status => status.get('id')));
  const wasLoaded = state.getIn([timeline, 'loaded']);
  const hadNext   = state.getIn([timeline, 'next']);
  const oldIds    = state.getIn([timeline, 'items'], Immutable.List());

  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    mMap.set('loaded', true);
    mMap.set('isLoading', false);
    if (!hadNext) mMap.set('next', next);
    mMap.set('items', wasLoaded ? ids.concat(oldIds) : ids);
  }));
};

const appendNormalizedTimeline = (state, timeline, statuses, next) => {
  const ids    = Immutable.List(statuses.map(status => status.get('id')));
  const oldIds = state.getIn([timeline, 'items'], Immutable.List());

  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    mMap.set('isLoading', false);
    mMap.set('next', next);
    mMap.set('items', oldIds.concat(ids));
  }));
};

const updateTimeline = (state, timeline, status, references) => {
  const top        = state.getIn([timeline, 'top']);
  const ids        = state.getIn([timeline, 'items'], Immutable.List());
  const includesId = ids.includes(status.get('id'));
  const unread     = state.getIn([timeline, 'unread'], 0);

  if (includesId) {
    return state;
  }

  let newIds = ids;

  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    if (!top) mMap.set('unread', unread + 1);
    if (top && ids.size > 40) newIds = newIds.take(20);
    if (status.getIn(['reblog', 'id'], null) !== null) newIds = newIds.filterNot(item => references.includes(item));
    mMap.set('items', newIds.unshift(status.get('id')));
  }));
};

const deleteStatus = (state, id, accountId, references, reblogOf) => {
  state.keySeq().forEach(timeline => {
    state = state.updateIn([timeline, 'items'], list => {
      if (reblogOf && !list.includes(reblogOf)) {
        return list.map(item => item === id ? reblogOf : item);
      } else {
        return list.filterNot(item => item === id);
      }
    });
  });

  // Remove reblogs of deleted status
  references.forEach(ref => {
    state = deleteStatus(state, ref[0], ref[1], []);
  });

  return state;
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

const updateTop = (state, timeline, top) => {
  return state.update(timeline, initialTimeline, map => map.withMutations(mMap => {
    if (top) mMap.set('unread', 0);
    mMap.set('top', top);
  }));
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
  case TIMELINE_REFRESH_REQUEST:
  case TIMELINE_EXPAND_REQUEST:
    return state.update(action.timeline, initialTimeline, map => map.set('isLoading', true));
  case TIMELINE_REFRESH_FAIL:
  case TIMELINE_EXPAND_FAIL:
    return state.update(action.timeline, initialTimeline, map => map.set('isLoading', false));
  case TIMELINE_REFRESH_SUCCESS:
    return normalizeTimeline(state, action.timeline, Immutable.fromJS(action.statuses), action.next);
  case TIMELINE_EXPAND_SUCCESS:
    return appendNormalizedTimeline(state, action.timeline, Immutable.fromJS(action.statuses), action.next);
  case TIMELINE_UPDATE:
    return updateTimeline(state, action.timeline, Immutable.fromJS(action.status), action.references);
  case TIMELINE_DELETE:
    return deleteStatus(state, action.id, action.accountId, action.references, action.reblogOf);
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return filterTimelines(state, action.relationship, action.statuses);
  case TIMELINE_SCROLL_TOP:
    return updateTop(state, action.timeline, action.top);
  case TIMELINE_CONNECT:
    return state.update(action.timeline, initialTimeline, map => map.set('online', true));
  case TIMELINE_DISCONNECT:
    return state.update(action.timeline, initialTimeline, map => map.set('online', false));
  default:
    return state;
  }
};
