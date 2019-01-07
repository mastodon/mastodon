import { FILTERS_FETCH_SUCCESS } from '../actions/filters';
import { List as ImmutableList, fromJS } from 'immutable';

export default function filters(state = ImmutableList(), action) {
  switch(action.type) {
  case FILTERS_FETCH_SUCCESS:
    return fromJS(action.filters);
  default:
    return state;
  }
};
