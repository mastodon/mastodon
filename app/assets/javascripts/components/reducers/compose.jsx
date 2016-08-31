import { COMPOSE_CHANGE, COMPOSE_SUBMIT_REQUEST, COMPOSE_SUBMIT_SUCCESS, COMPOSE_SUBMIT_FAIL } from '../actions/compose';
import Immutable                                                                               from 'immutable';

const initialState = Immutable.Map({
  text: '',
  in_reply_to_id: null,
  isSubmitting: false
});

export default function compose(state = initialState, action) {
  switch(action.type) {
    case COMPOSE_CHANGE:
      return state.set('text', action.text);
    case COMPOSE_SUBMIT_REQUEST:
      return state.set('isSubmitting', true);
    case COMPOSE_SUBMIT_SUCCESS:
      return state.withMutations(map => {
        map.set('text', '').set('isSubmitting', false);
      });
    case COMPOSE_SUBMIT_FAIL:
      return state.set('isSubmitting', false);
    default:
      return state;
  }
}
