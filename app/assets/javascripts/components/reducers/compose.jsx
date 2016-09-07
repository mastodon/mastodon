import * as constants      from '../actions/compose';
import { TIMELINE_DELETE } from '../actions/timelines';
import Immutable           from 'immutable';

const initialState = Immutable.Map({
  text: '',
  in_reply_to: null,
  is_submitting: false,
  is_uploading: false,
  progress: 0,
  media_attachments: Immutable.List([])
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
        map.set('in_reply_to', null);
        map.set('text', '');
      });
    case constants.COMPOSE_SUBMIT_REQUEST:
      return state.set('is_submitting', true);
    case constants.COMPOSE_SUBMIT_SUCCESS:
      return state.withMutations(map => {
        map.set('text', '');
        map.set('is_submitting', false);
        map.set('in_reply_to', null);
        map.update('media_attachments', list => list.clear());
      });
    case constants.COMPOSE_SUBMIT_FAIL:
      return state.set('is_submitting', false);
    case constants.COMPOSE_UPLOAD_REQUEST:
      return state.set('is_uploading', true);
    case constants.COMPOSE_UPLOAD_SUCCESS:
      return state.withMutations(map => {
        map.update('media_attachments', list => list.push(Immutable.fromJS(action.media)));
        map.set('is_uploading', false);
      });
    case constants.COMPOSE_UPLOAD_FAIL:
      return state.set('is_uploading', false);
    case constants.COMPOSE_UPLOAD_UNDO:
      return state.update('media_attachments', list => list.filterNot(item => item.get('id') === action.media_id));
    case constants.COMPOSE_UPLOAD_PROGRESS:
      return state.set('progress', Math.round((action.loaded / action.total) * 100));
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
