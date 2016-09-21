import {
  COMPOSE_CHANGE,
  COMPOSE_REPLY,
  COMPOSE_REPLY_CANCEL,
  COMPOSE_SUBMIT_REQUEST,
  COMPOSE_SUBMIT_SUCCESS,
  COMPOSE_SUBMIT_FAIL,
  COMPOSE_UPLOAD_REQUEST,
  COMPOSE_UPLOAD_SUCCESS,
  COMPOSE_UPLOAD_FAIL,
  COMPOSE_UPLOAD_UNDO,
  COMPOSE_UPLOAD_PROGRESS
}                          from '../actions/compose';
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

function statusToTextMentions(status) {
  return Immutable.OrderedSet([`@${status.getIn(['account', 'acct'])} `]).union(status.get('mentions').map(mention => `@${mention.get('acct')} `)).join('');
};

export default function compose(state = initialState, action) {
  switch(action.type) {
    case COMPOSE_CHANGE:
      return state.set('text', action.text);
    case COMPOSE_REPLY:
      return state.withMutations(map => {
        map.set('in_reply_to', action.status.get('id'));
        map.set('text', statusToTextMentions(action.status));
      });
    case COMPOSE_REPLY_CANCEL:
      return state.withMutations(map => {
        map.set('in_reply_to', null);
        map.set('text', '');
      });
    case COMPOSE_SUBMIT_REQUEST:
      return state.set('is_submitting', true);
    case COMPOSE_SUBMIT_SUCCESS:
      return state.withMutations(map => {
        map.set('text', '');
        map.set('is_submitting', false);
        map.set('in_reply_to', null);
        map.update('media_attachments', list => list.clear());
      });
    case COMPOSE_SUBMIT_FAIL:
      return state.set('is_submitting', false);
    case COMPOSE_UPLOAD_REQUEST:
      return state.set('is_uploading', true);
    case COMPOSE_UPLOAD_SUCCESS:
      return state.withMutations(map => {
        map.update('media_attachments', list => list.push(Immutable.fromJS(action.media)));
        map.set('is_uploading', false);
      });
    case COMPOSE_UPLOAD_FAIL:
      return state.set('is_uploading', false);
    case COMPOSE_UPLOAD_UNDO:
      return state.update('media_attachments', list => list.filterNot(item => item.get('id') === action.media_id));
    case COMPOSE_UPLOAD_PROGRESS:
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
};
