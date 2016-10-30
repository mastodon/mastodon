import {
  FOLLOW_CHANGE,
  FOLLOW_SUBMIT_REQUEST,
  FOLLOW_SUBMIT_SUCCESS,
  FOLLOW_SUBMIT_FAIL
} from '../actions/follow';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  text: '',
  is_submitting: false
});

export default function follow(state = initialState, action) {
  switch(action.type) {
    case FOLLOW_CHANGE:
      return state.set('text', action.text);
    case FOLLOW_SUBMIT_REQUEST:
      return state.set('is_submitting', true);
    case FOLLOW_SUBMIT_SUCCESS:
      return state.withMutations(map => {
        map.set('text', '').set('is_submitting', false);
      });
    case FOLLOW_SUBMIT_FAIL:
      return state.set('is_submitting', false);
    default:
      return state;
  }
};
