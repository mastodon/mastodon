import {
  NOTIFICATION_SHOW,
  NOTIFICATION_DISMISS,
  NOTIFICATION_CLEAR
}                            from '../actions/notifications';
import Immutable             from 'immutable';

const initialState = Immutable.List([]);

export default function notifications(state = initialState, action) {
  switch(action.type) {
    case NOTIFICATION_SHOW:
      return state.push(Immutable.Map({
        key: state.size > 0 ? state.last().get('key') + 1 : 0,
        title: action.title,
        message: action.message
      }));
    case NOTIFICATION_DISMISS:
      return state.filterNot(item => item.get('key') === action.notification.key);
    case NOTIFICATION_CLEAR:
      return state.clear();
    default:
      return state;
  }
};
