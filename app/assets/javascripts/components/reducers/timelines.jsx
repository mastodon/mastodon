import {
  TIMELINE_REFRESH_SUCCESS,
  TIMELINE_UPDATE,
  TIMELINE_DELETE,
  TIMELINE_EXPAND_SUCCESS
}                                from '../actions/timelines';
import {
  REBLOG_SUCCESS,
  UNREBLOG_SUCCESS,
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS
}                                from '../actions/interactions';
import {
  ACCOUNT_SET_SELF,
  ACCOUNT_FETCH_SUCCESS,
  ACCOUNT_FOLLOW_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_UNBLOCK_SUCCESS,
  ACCOUNT_TIMELINE_FETCH_SUCCESS,
  ACCOUNT_TIMELINE_EXPAND_SUCCESS
}                                from '../actions/accounts';
import {
  STATUS_FETCH_SUCCESS,
  STATUS_DELETE_SUCCESS
}                                from '../actions/statuses';
import { FOLLOW_SUBMIT_SUCCESS } from '../actions/follow';
import { SUGGESTIONS_FETCH_SUCCESS } from '../actions/suggestions';
import Immutable                 from 'immutable';

const initialState = Immutable.Map({
  home: Immutable.List([]),
  mentions: Immutable.List([]),
  public: Immutable.List([]),
  statuses: Immutable.Map(),
  accounts: Immutable.Map(),
  accounts_timelines: Immutable.Map(),
  me: null,
  ancestors: Immutable.Map(),
  descendants: Immutable.Map(),
  relationships: Immutable.Map(),
  suggestions: Immutable.List([])
});

function normalizeStatus(state, status) {
  // Separate account
  let account = status.get('account');
  status = status.set('account', account.get('id'));

  // Separate reblog, repeat for reblog
  let reblog = status.get('reblog');

  if (reblog !== null) {
    status = status.set('reblog', reblog.get('id'));
    state  = normalizeStatus(state, reblog);
  }

  // Replies
  if (status.get('in_reply_to_id')) {
    state = state.updateIn(['descendants', status.get('in_reply_to_id')], set => {
      if (!Immutable.OrderedSet.isOrderedSet(set)) {
        return Immutable.OrderedSet([status.get('id')]);
      } else {
        return set.add(status.get('id'));
      }
    });
  }

  return state.withMutations(map => {
    if (status.get('in_reply_to_id')) {
      map.updateIn(['descendants', status.get('in_reply_to_id')], Immutable.OrderedSet(), set => set.add(status.get('id')));
      map.updateIn(['ancestors', status.get('id')], Immutable.OrderedSet(), set => set.add(status.get('in_reply_to_id')));
    }

    map.setIn(['accounts', account.get('id')], account);
    map.setIn(['statuses', status.get('id')], status);
  });
};

function normalizeTimeline(state, timeline, statuses) {
  statuses.forEach((status, i) => {
    state = normalizeStatus(state, status);
    state = state.setIn([timeline, i], status.get('id'));
  });

  return state;
};

function appendNormalizedTimeline(state, timeline, statuses) {
  let moreIds = Immutable.List([]);

  statuses.forEach((status, i) => {
    state   = normalizeStatus(state, status);
    moreIds = moreIds.set(i, status.get('id'));
  });

  return state.update(timeline, list => list.push(...moreIds));
};

function normalizeAccountTimeline(state, accountId, statuses) {
  state = state.updateIn(['accounts_timelines', accountId], Immutable.List([]), list => {
    return (list.size > 0) ? list.clear() : list;
  });

  statuses.forEach((status, i) => {
    state = normalizeStatus(state, status);
    state = state.updateIn(['accounts_timelines', accountId], Immutable.List([]), list => list.set(i, status.get('id')));
  });

  return state;
};

function appendNormalizedAccountTimeline(state, accountId, statuses) {
  let moreIds = Immutable.List([]);

  statuses.forEach((status, i) => {
    state   = normalizeStatus(state, status);
    moreIds = moreIds.set(i, status.get('id'));
  });

  return state.updateIn(['accounts_timelines', accountId], Immutable.List([]), list => list.push(...moreIds));
};

function updateTimeline(state, timeline, status) {
  state = normalizeStatus(state, status);

  state = state.update(timeline, list => {
    const reblogOfId = status.getIn(['reblog', 'id'], null);

    if (reblogOfId !== null) {
      const otherReblogs = state.get('statuses').filter(item => item.get('reblog') === reblogOfId).map((_, itemId) => itemId);
      list = list.filterNot(itemId => (itemId === reblogOfId || otherReblogs.includes(itemId)));
    }

    return list.unshift(status.get('id'));
  });

  state = state.updateIn(['accounts_timelines', status.getIn(['account', 'id'])], Immutable.List([]), list => (list.includes(status.get('id')) ? list : list.unshift(status.get('id'))));

  return state;
};

function deleteStatus(state, id) {
  const status = state.getIn(['statuses', id]);

  if (!status) {
    return state;
  }

  // Remove references from timelines
  ['home', 'mentions'].forEach(function (timeline) {
    state = state.update(timeline, list => list.filterNot(item => item === id));
  });

  // Remove references from account timelines
  state = state.updateIn(['accounts_timelines', status.get('account')], Immutable.List([]), list => list.filterNot(item => item === id));

  // Remove reblogs of deleted status
  const references = state.get('statuses').filter(item => item.get('reblog') === id);

  references.forEach(referencingId => {
    state = deleteStatus(state, referencingId);
  });

  // Remove normalized status
  return state.deleteIn(['statuses', id]);
};

function normalizeAccount(state, account, relationship) {
  if (relationship) {
    state = normalizeRelationship(state, relationship);
  }

  return state.setIn(['accounts', account.get('id')], account);
};

function normalizeRelationship(state, relationship) {
  if (state.get('suggestions').includes(relationship.get('id')) && (relationship.get('following') || relationship.get('blocking'))) {
    state = state.update('suggestions', list => list.filterNot(id => id === relationship.get('id')));
  }

  return state.setIn(['relationships', relationship.get('id')], relationship);
};

function setSelf(state, account) {
  state = normalizeAccount(state, account);
  return state.set('me', account.get('id'));
};

function normalizeContext(state, status, ancestors, descendants) {
  state = normalizeStatus(state, status);

  let ancestorsIds = ancestors.map(ancestor => {
    state = normalizeStatus(state, ancestor);
    return ancestor.get('id');
  }).toOrderedSet();

  let descendantsIds = descendants.map(descendant => {
    state = normalizeStatus(state, descendant);
    return descendant.get('id');
  }).toOrderedSet();

  return state.withMutations(map => {
    map.setIn(['ancestors', status.get('id')], ancestorsIds);
    map.setIn(['descendants', status.get('id')], descendantsIds);
  });
};

function normalizeSuggestions(state, accounts) {
  accounts.forEach(account => {
    state = state.setIn(['accounts', account.get('id')], account);
  });

  return state.set('suggestions', accounts.map(account => account.get('id')));
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
    case TIMELINE_REFRESH_SUCCESS:
      return normalizeTimeline(state, action.timeline, Immutable.fromJS(action.statuses));
    case TIMELINE_EXPAND_SUCCESS:
      return appendNormalizedTimeline(state, action.timeline, Immutable.fromJS(action.statuses));
    case TIMELINE_UPDATE:
      return updateTimeline(state, action.timeline, Immutable.fromJS(action.status));
    case TIMELINE_DELETE:
    case STATUS_DELETE_SUCCESS:
      return deleteStatus(state, action.id);
    case REBLOG_SUCCESS:
    case FAVOURITE_SUCCESS:
    case UNREBLOG_SUCCESS:
    case UNFAVOURITE_SUCCESS:
      return normalizeStatus(state, Immutable.fromJS(action.response));
    case ACCOUNT_SET_SELF:
      return setSelf(state, Immutable.fromJS(action.account));
    case ACCOUNT_FETCH_SUCCESS:
    case FOLLOW_SUBMIT_SUCCESS:
      return normalizeAccount(state, Immutable.fromJS(action.account), Immutable.fromJS(action.relationship));
    case ACCOUNT_FOLLOW_SUCCESS:
    case ACCOUNT_UNFOLLOW_SUCCESS:
    case ACCOUNT_UNBLOCK_SUCCESS:
    case ACCOUNT_BLOCK_SUCCESS:
      return normalizeRelationship(state, Immutable.fromJS(action.relationship));
    case STATUS_FETCH_SUCCESS:
      return normalizeContext(state, Immutable.fromJS(action.status), Immutable.fromJS(action.context.ancestors), Immutable.fromJS(action.context.descendants));
    case ACCOUNT_TIMELINE_FETCH_SUCCESS:
      return normalizeAccountTimeline(state, action.id, Immutable.fromJS(action.statuses));
    case ACCOUNT_TIMELINE_EXPAND_SUCCESS:
      return appendNormalizedAccountTimeline(state, action.id, Immutable.fromJS(action.statuses));
    case SUGGESTIONS_FETCH_SUCCESS:
      return normalizeSuggestions(state, Immutable.fromJS(action.suggestions));
    default:
      return state;
  }
};
