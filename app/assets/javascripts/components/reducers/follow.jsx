import * as constants from '../actions/follow';
import Immutable                                                                                              from 'immutable';

const initialState = Immutable.Map({
  text: '',
  is_submitting: false
});

export default function compose(state = initialState, action) {
  switch(action.type) {
    case constants.FOLLOW_CHANGE:
      return state.set('text', action.text);
    case constants.FOLLOW_SUBMIT_REQUEST:
      return state.set('is_submitting', true);
    case constants.FOLLOW_SUBMIT_SUCCESS:
      return state.withMutations(map => {
        map.set('text', '').set('is_submitting', false);
      });
    case constants.FOLLOW_SUBMIT_FAIL:
      return state.set('is_submitting', false);
    default:
      return state;
  }
};
