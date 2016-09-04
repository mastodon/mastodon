import { TIMELINE_SET, TIMELINE_UPDATE, TIMELINE_DELETE } from '../actions/timelines';
import { REBLOG_SUCCESS, FAVOURITE_SUCCESS }              from '../actions/interactions';
import Immutable                                          from 'immutable';

const initialState = Immutable.Map({
  home: Immutable.List([]),
  mentions: Immutable.List([]),
  statuses: Immutable.Map(),
  accounts: Immutable.Map()
});

function statusToMaps(state, status) {
  // Separate account
  let account = status.get('account');
  status = status.set('account', account.get('id'));

  // Separate reblog, repeat for reblog
  let reblog = status.get('reblog');

  if (reblog !== null) {
    status = status.set('reblog', reblog.get('id'));
    state  = statusToMaps(state, reblog);
  }

  return state.withMutations(map => {
    map.setIn(['accounts', account.get('id')], account);
    map.setIn(['statuses', status.get('id')], status);
  });
};

function timelineToMaps(state, timeline, statuses) {
  statuses.forEach((status, i) => {
    state = statusToMaps(state, status);
    state = state.setIn([timeline, i], status.get('id'));
  });

  return state;
};

function updateTimelineWithMaps(state, timeline, status) {
  state = statusToMaps(state, status);
  state = state.update(timeline, list => list.unshift(status.get('id')));

  return state;
};

function deleteStatus(state, id) {
  ['home', 'mentions'].forEach(function (timeline) {
    state = state.update(timeline, list => list.filterNot(item => item === id));
  });

  return state.deleteIn(['statuses', id]);
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
    case TIMELINE_SET:
      return timelineToMaps(state, action.timeline, Immutable.fromJS(action.statuses));
    case TIMELINE_UPDATE:
      return updateTimelineWithMaps(state, action.timeline, Immutable.fromJS(action.status));
    case TIMELINE_DELETE:
      return deleteStatus(state, action.id);
    case REBLOG_SUCCESS:
    case FAVOURITE_SUCCESS:
      return statusToMaps(state, Immutable.fromJS(action.response));
    default:
      return state;
  }
}
