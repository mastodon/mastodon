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
}                           from '../actions/compose';
import { TIMELINE_DELETE }  from '../actions/timelines';
import { ACCOUNT_SET_SELF } from '../actions/accounts';
import Immutable            from 'immutable';

const initialState = Immutable.Map({
  text: '',
  in_reply_to: null,
  is_submitting: false,
  is_uploading: false,
  progress: 0,
  media_attachments: Immutable.List([]),
  me: null
});

function statusToTextMentions(state, status) {
  let set = Immutable.OrderedSet([]);
  let me  = state.get('me');

  if (status.getIn(['account', 'id']) !== me) {
    set = set.add(`@${status.getIn(['account', 'acct'])} `);
  }
  
  return set.union(status.get('mentions').filterNot(mention => mention.get('id') === me).map(mention => `@${mention.get('acct')} `)).join('');
};

function clearAll(state) {
  return state.withMutations(map => {
    map.set('text', '');
    map.set('is_submitting', false);
    map.set('in_reply_to', null);
    map.update('media_attachments', list => list.clear());
  });
};

function appendMedia(state, media) {
  return state.withMutations(map => {
    map.update('media_attachments', list => list.push(media));
    map.set('is_uploading', false);
    map.update('text', oldText => `${oldText} ${media.get('text_url')}`.trim());
  });
};

function removeMedia(state, mediaId) {
  const media = state.get('media_attachments').find(item => item.get('id') === mediaId);

  return state.withMutations(map => {
    map.update('media_attachments', list => list.filterNot(item => item.get('id') === mediaId));
    map.update('text', text => text.replace(media.get('text_url'), '').trim());
  });
};

export default function compose(state = initialState, action) {
  switch(action.type) {
    case COMPOSE_CHANGE:
      return state.set('text', action.text);
    case COMPOSE_REPLY:
      return state.withMutations(map => {
        map.set('in_reply_to', action.status.get('id'));
        map.set('text', statusToTextMentions(state, action.status));
      });
    case COMPOSE_REPLY_CANCEL:
      return state.withMutations(map => {
        map.set('in_reply_to', null);
        map.set('text', '');
      });
    case COMPOSE_SUBMIT_REQUEST:
      return state.set('is_submitting', true);
    case COMPOSE_SUBMIT_SUCCESS:
      return clearAll(state);
    case COMPOSE_SUBMIT_FAIL:
      return state.set('is_submitting', false);
    case COMPOSE_UPLOAD_REQUEST:
      return state.set('is_uploading', true);
    case COMPOSE_UPLOAD_SUCCESS:
      return appendMedia(state, Immutable.fromJS(action.media));
    case COMPOSE_UPLOAD_FAIL:
      return state.set('is_uploading', false);
    case COMPOSE_UPLOAD_UNDO:
      return removeMedia(state, action.media_id);
    case COMPOSE_UPLOAD_PROGRESS:
      return state.set('progress', Math.round((action.loaded / action.total) * 100));
    case TIMELINE_DELETE:
      if (action.id === state.get('in_reply_to')) {
        return state.set('in_reply_to', null);
      } else {
        return state;
      }
    case ACCOUNT_SET_SELF:
      return state.set('me', action.account.id);
    default:
      return state;
  }
};
