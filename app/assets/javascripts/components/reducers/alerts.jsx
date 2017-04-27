import {
  ALERT_SHOW,
  ALERT_DISMISS,
  ALERT_CLEAR
} from '../actions/alerts';
import Immutable from 'immutable';

const initialState = Immutable.List([]);

export default function alerts(state = initialState, action) {
  switch(action.type) {
  case ALERT_SHOW:
    return state.push(Immutable.Map({
      key: state.size > 0 ? state.last().get('key') + 1 : 0,
      title: action.title,
      message: action.message
    }));
  case ALERT_DISMISS:
    return state.filterNot(item => item.get('key') === action.alert.key);
  case ALERT_CLEAR:
    return state.clear();
  default:
    return state;
  }
};
