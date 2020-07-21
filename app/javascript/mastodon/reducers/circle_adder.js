import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  CIRCLE_ADDER_RESET,
  CIRCLE_ADDER_SETUP,
  CIRCLE_ADDER_CIRCLES_FETCH_REQUEST,
  CIRCLE_ADDER_CIRCLES_FETCH_SUCCESS,
  CIRCLE_ADDER_CIRCLES_FETCH_FAIL,
  CIRCLE_EDITOR_ADD_SUCCESS,
  CIRCLE_EDITOR_REMOVE_SUCCESS,
} from '../actions/circles';

const initialState = ImmutableMap({
  accountId: null,

  circles: ImmutableMap({
    items: ImmutableList(),
    loaded: false,
    isLoading: false,
  }),
});

export default function circleAdderReducer(state = initialState, action) {
  switch(action.type) {
  case CIRCLE_ADDER_RESET:
    return initialState;
  case CIRCLE_ADDER_SETUP:
    return state.withMutations(map => {
      map.set('accountId', action.account.get('id'));
    });
  case CIRCLE_ADDER_CIRCLES_FETCH_REQUEST:
    return state.setIn(['circles', 'isLoading'], true);
  case CIRCLE_ADDER_CIRCLES_FETCH_FAIL:
    return state.setIn(['circles', 'isLoading'], false);
  case CIRCLE_ADDER_CIRCLES_FETCH_SUCCESS:
    return state.update('circles', circles => circles.withMutations(map => {
      map.set('isLoading', false);
      map.set('loaded', true);
      map.set('items', ImmutableList(action.circles.map(item => item.id)));
    }));
  case CIRCLE_EDITOR_ADD_SUCCESS:
    return state.updateIn(['circles', 'items'], circle => circle.unshift(action.circleId));
  case CIRCLE_EDITOR_REMOVE_SUCCESS:
    return state.updateIn(['circles', 'items'], circle => circle.filterNot(item => item === action.circleId));
  default:
    return state;
  }
};
