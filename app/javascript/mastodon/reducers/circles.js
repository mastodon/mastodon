import {
  CIRCLE_FETCH_SUCCESS,
  CIRCLE_FETCH_FAIL,
  CIRCLES_FETCH_SUCCESS,
  CIRCLE_CREATE_SUCCESS,
  CIRCLE_UPDATE_SUCCESS,
  CIRCLE_DELETE_SUCCESS,
} from '../actions/circles';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap();

const normalizeCircle = (state, circle) => state.set(circle.id, fromJS(circle));

const normalizeCircles = (state, circles) => {
  circles.forEach(circle => {
    state = normalizeCircle(state, circle);
  });

  return state;
};

export default function circles(state = initialState, action) {
  switch(action.type) {
  case CIRCLE_FETCH_SUCCESS:
  case CIRCLE_CREATE_SUCCESS:
  case CIRCLE_UPDATE_SUCCESS:
    return normalizeCircle(state, action.circle);
  case CIRCLES_FETCH_SUCCESS:
    return normalizeCircles(state, action.circles);
  case CIRCLE_DELETE_SUCCESS:
  case CIRCLE_FETCH_FAIL:
    return state.set(action.id, false);
  default:
    return state;
  }
};
