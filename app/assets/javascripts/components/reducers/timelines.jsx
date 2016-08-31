import { TIMELINE_SET, TIMELINE_UPDATE } from '../actions/timelines';
import Immutable                         from 'immutable';

const initialState = Immutable.Map();

export default function timelines(state = initialState, action) {
  switch(action.type) {
    case TIMELINE_SET:
      return state.set(action.timeline, Immutable.fromJS(action.statuses));
    case TIMELINE_UPDATE:
      return state.update(action.timeline, function (list) {
        return list.unshift(Immutable.fromJS(action.status));
      });
    default:
      return state;
  }
}
