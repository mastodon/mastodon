import {
  TIMELINE_REFRESH_SUCCESS,
  TIMELINE_UPDATE,
  TIMELINE_DELETE,
  TIMELINE_EXPAND_SUCCESS
} from '../actions/timelines';
import {
  REBLOG_SUCCESS,
  UNREBLOG_SUCCESS,
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS
} from '../actions/interactions';
import {
  ACCOUNT_FETCH_SUCCESS,
  ACCOUNT_TIMELINE_FETCH_SUCCESS,
  ACCOUNT_TIMELINE_EXPAND_SUCCESS
} from '../actions/accounts';
import {
  STATUS_FETCH_SUCCESS,
  CONTEXT_FETCH_SUCCESS
} from '../actions/statuses';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  home: Immutable.List(),
  mentions: Immutable.List(),
  public: Immutable.List(),
  tag: Immutable.List(),
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

const normalizeTimeline = (state, timeline, statuses, replace = false) => {
  let ids = Immutable.List();

  statuses.forEach((status, i) => {
    state = normalizeStatus(state, status);
    ids   = ids.set(i, status.get('id'));
  });

  return state.update(timeline, Immutable.List(), list => (replace ? ids : list.unshift(...ids)));
};

const appendNormalizedTimeline = (state, timeline, statuses) => {
  let moreIds = Immutable.List();

  statuses.forEach((status, i) => {
    state   = normalizeStatus(state, status);
    moreIds = moreIds.set(i, status.get('id'));
  });

  return state.update(timeline, Immutable.List(), list => list.push(...moreIds));
};

const normalizeAccountTimeline = (state, accountId, statuses, replace = false) => {
  let ids = Immutable.List();

  statuses.forEach((status, i) => {
    state = normalizeStatus(state, status);
    ids   = ids.set(i, status.get('id'));
  });

  return state.updateIn(['accounts_timelines', accountId], Immutable.List([]), list => (replace ? ids : list.unshift(...ids)));
};

const appendNormalizedAccountTimeline = (state, accountId, statuses) => {
  let moreIds = Immutable.List([]);

  statuses.forEach((status, i) => {
    state   = normalizeStatus(state, status);
    moreIds = moreIds.set(i, status.get('id'));
  });

  return state.updateIn(['accounts_timelines', accountId], Immutable.List([]), list => list.push(...moreIds));
};

const updateTimeline = (state, timeline, status, references) => {
  state = normalizeStatus(state, status);

  state = state.update(timeline, Immutable.List(), list => {
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

const deleteStatus = (state, id, accountId, references) => {
  // Remove references from timelines
  ['home', 'mentions', 'public', 'tag'].forEach(function (timeline) {
    state = state.update(timeline, list => list.filterNot(item => item === id));
  });

  // Remove references from account timelines
  state = state.updateIn(['accounts_timelines', accountId], Immutable.List([]), list => list.filterNot(item => item === id));

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

const normalizeContext = (state, id, ancestors, descendants) => {
  const ancestorsIds   = ancestors.map(ancestor => ancestor.get('id'));
  const descendantsIds = descendants.map(descendant => descendant.get('id'));

  return state.withMutations(map => {
    map.setIn(['ancestors', id], ancestorsIds);
    map.setIn(['descendants', id], descendantsIds);
  });
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
    case TIMELINE_REFRESH_SUCCESS:
      return normalizeTimeline(state, action.timeline, Immutable.fromJS(action.statuses), action.replace);
    case TIMELINE_EXPAND_SUCCESS:
      return appendNormalizedTimeline(state, action.timeline, Immutable.fromJS(action.statuses));
    case TIMELINE_UPDATE:
      return updateTimeline(state, action.timeline, Immutable.fromJS(action.status), action.references);
    case TIMELINE_DELETE:
      return deleteStatus(state, action.id, action.accountId, action.references);
    case CONTEXT_FETCH_SUCCESS:
      return normalizeContext(state, action.id, Immutable.fromJS(action.ancestors), Immutable.fromJS(action.descendants));
    case ACCOUNT_TIMELINE_FETCH_SUCCESS:
      return normalizeAccountTimeline(state, action.id, Immutable.fromJS(action.statuses), action.replace);
    case ACCOUNT_TIMELINE_EXPAND_SUCCESS:
      return appendNormalizedAccountTimeline(state, action.id, Immutable.fromJS(action.statuses));
    default:
      return state;
  }
};
