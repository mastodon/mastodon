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
  TIMELINE_DISCONNECT
} from '../actions/timelines';
import {
  REBLOG_SUCCESS,
  UNREBLOG_SUCCESS,
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS
} from '../actions/interactions';
import {
  ACCOUNT_TIMELINE_FETCH_REQUEST,
  ACCOUNT_TIMELINE_FETCH_SUCCESS,
  ACCOUNT_TIMELINE_FETCH_FAIL,
  ACCOUNT_TIMELINE_EXPAND_REQUEST,
  ACCOUNT_TIMELINE_EXPAND_SUCCESS,
  ACCOUNT_TIMELINE_EXPAND_FAIL,
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS
} from '../actions/accounts';
import {
  CONTEXT_FETCH_SUCCESS
} from '../actions/statuses';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  home: Immutable.Map({
    path: () => '/api/v1/timelines/home',
    next: null,
    isLoading: false,
    online: false,
    loaded: false,
    top: true,
    unread: 0,
    items: Immutable.List()
  }),

  public: Immutable.Map({
    path: () => '/api/v1/timelines/public',
    next: null,
    isLoading: false,
    online: false,
    loaded: false,
    top: true,
    unread: 0,
    items: Immutable.List()
  }),

  community: Immutable.Map({
    path: () => '/api/v1/timelines/public',
    next: null,
    params: { local: true },
    isLoading: false,
    online: false,
    loaded: false,
    top: true,
    unread: 0,
    items: Immutable.List()
  }),

  tag: Immutable.Map({
    path: (id) => `/api/v1/timelines/tag/${id}`,
    next: null,
    isLoading: false,
    id: null,
    loaded: false,
    top: true,
    unread: 0,
    items: Immutable.List()
  }),

  accounts_timelines: Immutable.Map(),
  ancestors: Immutable.Map(),
  descendants: Immutable.Map()
});

const normalizeStatus = (state, status) => {
  const replyToId = status.get('in_reply_to_id');
  const id        = status.get('id');

  if (replyToId) {
    if (!state.getIn(['descendants', replyToId], Immutable.List()).includes(id)) {
      state = state.updateIn(['descendants', replyToId], Immutable.List(), set => set.push(id));
    }

    if (!state.getIn(['ancestors', id], Immutable.List()).includes(replyToId)) {
      state = state.updateIn(['ancestors', id], Immutable.List(), set => set.push(replyToId));
    }
  }

  return state;
};

const normalizeTimeline = (state, timeline, statuses, next) => {
  let ids      = Immutable.List();
  const loaded = state.getIn([timeline, 'loaded']);

  statuses.forEach((status, i) => {
    state = normalizeStatus(state, status);
    ids   = ids.set(i, status.get('id'));
  });

  state = state.setIn([timeline, 'loaded'], true);
  state = state.setIn([timeline, 'isLoading'], false);

  if (state.getIn([timeline, 'next']) === null) {
    state = state.setIn([timeline, 'next'], next);
  }

  return state.updateIn([timeline, 'items'], Immutable.List(), list => (loaded ? ids.concat(list) : ids));
};

const appendNormalizedTimeline = (state, timeline, statuses, next) => {
  let moreIds = Immutable.List();

  statuses.forEach((status, i) => {
    state   = normalizeStatus(state, status);
    moreIds = moreIds.set(i, status.get('id'));
  });

  state = state.setIn([timeline, 'isLoading'], false);
  state = state.setIn([timeline, 'next'], next);

  return state.updateIn([timeline, 'items'], Immutable.List(), list => list.concat(moreIds));
};

const normalizeAccountTimeline = (state, accountId, statuses, replace = false) => {
  let ids = Immutable.List();

  statuses.forEach((status, i) => {
    state = normalizeStatus(state, status);
    ids   = ids.set(i, status.get('id'));
  });

  return state.updateIn(['accounts_timelines', accountId], Immutable.Map(), map => map
    .set('isLoading', false)
    .set('loaded', true)
    .set('next', true)
    .update('items', Immutable.List(), list => (replace ? ids : ids.concat(list))));
};

const appendNormalizedAccountTimeline = (state, accountId, statuses, next) => {
  let moreIds = Immutable.List([]);

  statuses.forEach((status, i) => {
    state   = normalizeStatus(state, status);
    moreIds = moreIds.set(i, status.get('id'));
  });

  return state.updateIn(['accounts_timelines', accountId], Immutable.Map(), map => map
    .set('isLoading', false)
    .set('next', next)
    .update('items', list => list.concat(moreIds)));
};

const updateTimeline = (state, timeline, status, references) => {
  const top = state.getIn([timeline, 'top']);

  state = normalizeStatus(state, status);

  if (!top) {
    state = state.updateIn([timeline, 'unread'], unread => unread + 1);
  }

  state = state.updateIn([timeline, 'items'], Immutable.List(), list => {
    if (top && list.size > 40) {
      list = list.take(20);
    }

    if (list.includes(status.get('id'))) {
      return list;
    }

    const reblogOfId = status.getIn(['reblog', 'id'], null);

    if (reblogOfId !== null) {
      list = list.filterNot(itemId => references.includes(itemId));
    }

    return list.unshift(status.get('id'));
  });

  return state;
};

const deleteStatus = (state, id, accountId, references, reblogOf) => {
  if (reblogOf) {
    // If we are deleting a reblog, just replace reblog with its original
    return state.updateIn(['home', 'items'], list => list.map(item => item === id ? reblogOf : item));
  }

  // Remove references from timelines
  ['home', 'public', 'community', 'tag'].forEach(function (timeline) {
    state = state.updateIn([timeline, 'items'], list => list.filterNot(item => item === id));
  });

  // Remove references from account timelines
  state = state.updateIn(['accounts_timelines', accountId, 'items'], Immutable.List([]), list => list.filterNot(item => item === id));

  // Remove references from context
  state.getIn(['descendants', id], Immutable.List()).forEach(descendantId => {
    state = state.updateIn(['ancestors', descendantId], Immutable.List(), list => list.filterNot(itemId => itemId === id));
  });

  state.getIn(['ancestors', id], Immutable.List()).forEach(ancestorId => {
    state = state.updateIn(['descendants', ancestorId], Immutable.List(), list => list.filterNot(itemId => itemId === id));
  });

  state = state.deleteIn(['descendants', id]).deleteIn(['ancestors', id]);

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
    state = deleteStatus(state, status.get('id'), status.get('account'), references);
  });

  return state;
};

const normalizeContext = (state, id, ancestors, descendants) => {
  const ancestorsIds   = ancestors.map(ancestor => ancestor.get('id'));
  const descendantsIds = descendants.map(descendant => descendant.get('id'));

  return state.withMutations(map => {
    map.setIn(['ancestors', id], ancestorsIds);
    map.setIn(['descendants', id], descendantsIds);
  });
};

const resetTimeline = (state, timeline, id) => {
  if (timeline === 'tag' && typeof id !== 'undefined' && state.getIn([timeline, 'id']) !== id) {
    state = state.update(timeline, map => map
        .set('id', id)
        .set('isLoading', true)
        .set('loaded', false)
        .set('next', null)
        .set('top', true)
        .update('items', list => list.clear()));
  } else {
    state = state.setIn([timeline, 'isLoading'], true);
  }

  return state;
};

const updateTop = (state, timeline, top) => {
  if (top) {
    state = state.setIn([timeline, 'unread'], 0);
  }

  return state.setIn([timeline, 'top'], top);
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
  case TIMELINE_REFRESH_REQUEST:
  case TIMELINE_EXPAND_REQUEST:
    return resetTimeline(state, action.timeline, action.id);
  case TIMELINE_REFRESH_FAIL:
  case TIMELINE_EXPAND_FAIL:
    return state.setIn([action.timeline, 'isLoading'], false);
  case TIMELINE_REFRESH_SUCCESS:
    return normalizeTimeline(state, action.timeline, Immutable.fromJS(action.statuses), action.next);
  case TIMELINE_EXPAND_SUCCESS:
    return appendNormalizedTimeline(state, action.timeline, Immutable.fromJS(action.statuses), action.next);
  case TIMELINE_UPDATE:
    return updateTimeline(state, action.timeline, Immutable.fromJS(action.status), action.references);
  case TIMELINE_DELETE:
    return deleteStatus(state, action.id, action.accountId, action.references, action.reblogOf);
  case CONTEXT_FETCH_SUCCESS:
    return normalizeContext(state, action.id, Immutable.fromJS(action.ancestors), Immutable.fromJS(action.descendants));
  case ACCOUNT_TIMELINE_FETCH_REQUEST:
  case ACCOUNT_TIMELINE_EXPAND_REQUEST:
    return state.updateIn(['accounts_timelines', action.id], Immutable.Map(), map => map.set('isLoading', true));
  case ACCOUNT_TIMELINE_FETCH_FAIL:
  case ACCOUNT_TIMELINE_EXPAND_FAIL:
    return state.updateIn(['accounts_timelines', action.id], Immutable.Map(), map => map.set('isLoading', false));
  case ACCOUNT_TIMELINE_FETCH_SUCCESS:
    return normalizeAccountTimeline(state, action.id, Immutable.fromJS(action.statuses), action.replace);
  case ACCOUNT_TIMELINE_EXPAND_SUCCESS:
    return appendNormalizedAccountTimeline(state, action.id, Immutable.fromJS(action.statuses), action.next);
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return filterTimelines(state, action.relationship, action.statuses);
  case TIMELINE_SCROLL_TOP:
    return updateTop(state, action.timeline, action.top);
  case TIMELINE_CONNECT:
    return state.setIn([action.timeline, 'online'], true);
  case TIMELINE_DISCONNECT:
    return state.setIn([action.timeline, 'online'], false);
  default:
    return state;
  }
};
