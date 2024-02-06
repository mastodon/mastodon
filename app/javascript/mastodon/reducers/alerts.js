import { List as ImmutableList } from 'immutable';

import {
  ALERT_SHOW,
  ALERT_DISMISS,
  ALERT_CLEAR,
} from '../actions/alerts';

const initialState = ImmutableList([]);

let id = 0;

const addAlert = (state, alert) =>
  state.push({
    key: id++,
    ...alert,
  });

export default function alerts(state = initialState, action) {
  switch(action.type) {
  case ALERT_SHOW:
    return addAlert(state, action.alert);
  case ALERT_DISMISS:
    return state.filterNot(item => item.key === action.alert.key);
  case ALERT_CLEAR:
    return state.clear();
  default:
    return state;
  }
}
