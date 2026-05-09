import { Map, fromJS } from 'immutable';
import {
  SCHEDULED_STATUSES_FETCH_SUCCESS,
  SCHEDULED_STATUS_CANCEL_SUCCESS,
} from '../actions/scheduled_statuses';

export default function scheduled_statuses(state = Map(), action) {
  switch(action.type) {
  case SCHEDULED_STATUSES_FETCH_SUCCESS:
    return Map(action.statuses.map(s => [s.id, fromJS(s)]));
  case SCHEDULED_STATUS_CANCEL_SUCCESS:
    return state.delete(action.id);
  default:
    return state;
  }
}