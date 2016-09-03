import { TIMELINE_SET, TIMELINE_UPDATE }    from '../actions/timelines';
import { REBLOG_SUCCESS, FAVOURITE_SUCCESS } from '../actions/interactions';
import Immutable                            from 'immutable';

const initialState = Immutable.Map();

function updateMatchingStatuses(state, needle, callback) {
  return state.map(function (list) {
    return list.map(function (status) {
      if (status.get('id') === needle.get('id')) {
        return callback(status);
      } else if (status.getIn(['reblog', 'id'], null) === needle.get('id')) {
        return status.set('reblog', callback(status.get('reblog')));
      }

      return status;
    });
  });
};

export default function timelines(state = initialState, action) {
  switch(action.type) {
    case TIMELINE_SET:
      return state.set(action.timeline, Immutable.fromJS(action.statuses));
    case TIMELINE_UPDATE:
      return state.update(action.timeline, list => list.unshift(Immutable.fromJS(action.status)));
    case REBLOG_SUCCESS:
    case FAVOURITE_SUCCESS:
      return updateMatchingStatuses(state, action.status, () => Immutable.fromJS(action.response));
    default:
      return state;
  }
}
