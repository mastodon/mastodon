import { SET_TIMELINE, ADD_STATUS } from '../actions/statuses';
import Immutable                    from 'immutable';

const initialState = Immutable.Map();

export default function statuses(state = initialState, action) {
  switch(action.type) {
    case SET_TIMELINE:
      return state.set(action.timeline, Immutable.fromJS(action.statuses));
    case ADD_STATUS:
      return state.update(action.timeline, function (list) {
        list.unshift(Immutable.fromJS(action.status));
      });
    default:
      return state;
  }
}
