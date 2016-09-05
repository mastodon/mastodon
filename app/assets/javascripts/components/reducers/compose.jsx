import * as constants      from '../actions/compose';
import { TIMELINE_DELETE } from '../actions/timelines';
import Immutable           from 'immutable';

const initialState = Immutable.Map({
  text: '',
  in_reply_to: null,
  is_submitting: false
});

export default function compose(state = initialState, action) {
  switch(action.type) {
    case constants.COMPOSE_CHANGE:
      return state.set('text', action.text);
    case constants.COMPOSE_REPLY:
      return state.withMutations(map => {
        map.set('in_reply_to', action.status.get('id'));
        map.set('text', `@${action.status.getIn(['account', 'acct'])} `);
      });
    case constants.COMPOSE_REPLY_CANCEL:
      return state.withMutations(map => {
        map.set('in_reply_to', null).set('text', '');
      });
    case constants.COMPOSE_SUBMIT_REQUEST:
      return state.set('is_submitting', true);
    case constants.COMPOSE_SUBMIT_SUCCESS:
      return state.withMutations(map => {
        map.set('text', '').set('is_submitting', false).set('in_reply_to', null);
      });
    case constants.COMPOSE_SUBMIT_FAIL:
      return state.set('is_submitting', false);
    case TIMELINE_DELETE:
      if (action.id === state.get('in_reply_to')) {
        return state.set('in_reply_to', null);
      } else {
        return state;
      }
    default:
      return state;
  }
}
