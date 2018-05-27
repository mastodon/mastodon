import { TRENDS_FETCH_SUCCESS } from '../actions/trends';
import { fromJS } from 'immutable';

const initialState = null;

export default function trendsReducer(state = initialState, action) {
  switch(action.type) {
  case TRENDS_FETCH_SUCCESS:
    return fromJS(action.trends);
  default:
    return state;
  }
};
