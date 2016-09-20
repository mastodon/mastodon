import {
  TIMELINE_REFRESH_SUCCESS,
  TIMELINE_UPDATE,
  TIMELINE_DELETE
}                                from '../actions/timelines';
import {
  REBLOG_SUCCESS,
  FAVOURITE_SUCCESS
}                                from '../actions/interactions';
import {
  ACCOUNT_SET_SELF,
  ACCOUNT_FETCH_SUCCESS,
  ACCOUNT_FOLLOW_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
  ACCOUNT_TIMELINE_FETCH_SUCCESS
}                                from '../actions/accounts';
import { STATUS_FETCH_SUCCESS }  from '../actions/statuses';
import { FOLLOW_SUBMIT_SUCCESS } from '../actions/follow';
import Immutable                 from 'immutable';

const initialState = Immutable.Map({
  home: Immutable.List([]),
  mentions: Immutable.List([]),
  statuses: Immutable.Map(),
  accounts: Immutable.Map(),
  accounts_timelines: Immutable.Map(),
  me: null,
  ancestors: Immutable.Map(),
  descendants: Immutable.Map()
});

export function selectStatus(state, id) {
  let status = state.getIn(['timelines', 'statuses', id], null);

  if (status === null) {
    return null;
  }

  status = status.set('account', state.getIn(['timelines', 'accounts', status.get('account')]));

  if (status.get('reblog') !== null) {
    status = status.set('reblog', selectStatus(state, status.get('reblog')));
  }

  return status;
};

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

function normalizeAccountTimeline(state, accountId, statuses) {
  statuses.forEach((status, i) => {
    state = normalizeStatus(state, status);
    state = state.updateIn(['accounts_timelines', accountId], Immutable.List(), list => list.set(i, status.get('id')));
  });

  return state;
};

function updateTimeline(state, timeline, status) {
  state = normalizeStatus(state, status);
  state = state.update(timeline, list => list.unshift(status.get('id')));
  state = state.updateIn(['accounts_timelines', status.getIn(['account', 'id'])], Immutable.List(), list => list.unshift(status.get('id')));

  return state;
};

function deleteStatus(state, id) {
  ['home', 'mentions'].forEach(function (timeline) {
    state = state.update(timeline, list => list.filterNot(item => item === id));
  });

  return state.deleteIn(['statuses', id]);
};

function normalizeAccount(state, account) {
  return state.setIn(['accounts', account.get('id')], account);
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

export default function timelines(state = initialState, action) {
  switch(action.type) {
    case TIMELINE_REFRESH_SUCCESS:
      return normalizeTimeline(state, action.timeline, Immutable.fromJS(action.statuses));
    case TIMELINE_UPDATE:
      return updateTimeline(state, action.timeline, Immutable.fromJS(action.status));
    case TIMELINE_DELETE:
      return deleteStatus(state, action.id);
    case REBLOG_SUCCESS:
    case FAVOURITE_SUCCESS:
      return normalizeStatus(state, Immutable.fromJS(action.response));
    case ACCOUNT_SET_SELF:
      return state.withMutations(map => {
        map.setIn(['accounts', action.account.id], Immutable.fromJS(action.account));
        map.set('me', action.account.id);
      });
    case ACCOUNT_FETCH_SUCCESS:
    case FOLLOW_SUBMIT_SUCCESS:
    case ACCOUNT_FOLLOW_SUCCESS:
    case ACCOUNT_UNFOLLOW_SUCCESS:
      return normalizeAccount(state, Immutable.fromJS(action.account));
    case STATUS_FETCH_SUCCESS:
      return normalizeContext(state, Immutable.fromJS(action.status), Immutable.fromJS(action.context.ancestors), Immutable.fromJS(action.context.descendants));
    case ACCOUNT_TIMELINE_FETCH_SUCCESS:
      return normalizeAccountTimeline(state, action.id, Immutable.fromJS(action.statuses));
    default:
      return state;
  }
};
