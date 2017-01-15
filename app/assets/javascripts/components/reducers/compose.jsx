import {
  COMPOSE_MOUNT,
  COMPOSE_UNMOUNT,
  COMPOSE_CHANGE,
  COMPOSE_REPLY,
  COMPOSE_REPLY_CANCEL,
  COMPOSE_MENTION,
  COMPOSE_SUBMIT_REQUEST,
  COMPOSE_SUBMIT_SUCCESS,
  COMPOSE_SUBMIT_FAIL,
  COMPOSE_UPLOAD_REQUEST,
  COMPOSE_UPLOAD_SUCCESS,
  COMPOSE_UPLOAD_FAIL,
  COMPOSE_UPLOAD_UNDO,
  COMPOSE_UPLOAD_PROGRESS,
  COMPOSE_SUGGESTIONS_CLEAR,
  COMPOSE_SUGGESTIONS_READY,
  COMPOSE_SUGGESTION_SELECT,
  COMPOSE_SENSITIVITY_CHANGE,
  COMPOSE_VISIBILITY_CHANGE,
  COMPOSE_LISTABILITY_CHANGE
} from '../actions/compose';
import { TIMELINE_DELETE } from '../actions/timelines';
import { STORE_HYDRATE } from '../actions/store';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  mounted: false,
  sensitive: false,
  unlisted: false,
  private: false,
  text: '',
  fileDropDate: null,
  in_reply_to: null,
  is_submitting: false,
  is_uploading: false,
  progress: 0,
  media_attachments: Immutable.List(),
  suggestion_token: null,
  suggestions: Immutable.List(),
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

const insertSuggestion = (state, position, token, completion) => {
  return state.withMutations(map => {
    map.update('text', oldText => `${oldText.slice(0, position)}${completion}${oldText.slice(position + token.length)}`);
    map.set('suggestion_token', null);
    map.update('suggestions', Immutable.List(), list => list.clear());
  });
};

export default function compose(state = initialState, action) {
  switch(action.type) {
    case STORE_HYDRATE:
      return state.merge(action.state.get('compose'));
    case COMPOSE_MOUNT:
      return state.set('mounted', true);
    case COMPOSE_UNMOUNT:
      return state.set('mounted', false);
    case COMPOSE_SENSITIVITY_CHANGE:
      return state.set('sensitive', action.checked);
    case COMPOSE_VISIBILITY_CHANGE:
      return state.set('private', action.checked);
    case COMPOSE_LISTABILITY_CHANGE:
      return state.set('unlisted', action.checked);
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
      return state.withMutations(map => {
        map.set('is_uploading', true);
        map.set('fileDropDate', new Date());
      });
    case COMPOSE_UPLOAD_SUCCESS:
      return appendMedia(state, Immutable.fromJS(action.media));
    case COMPOSE_UPLOAD_FAIL:
      return state.set('is_uploading', false);
    case COMPOSE_UPLOAD_UNDO:
      return removeMedia(state, action.media_id);
    case COMPOSE_UPLOAD_PROGRESS:
      return state.set('progress', Math.round((action.loaded / action.total) * 100));
    case COMPOSE_MENTION:
      return state.update('text', text => `${text}@${action.account.get('acct')} `);
    case COMPOSE_SUGGESTIONS_CLEAR:
      return state.update('suggestions', Immutable.List(), list => list.clear()).set('suggestion_token', null);
    case COMPOSE_SUGGESTIONS_READY:
      return state.set('suggestions', Immutable.List(action.accounts.map(item => item.id))).set('suggestion_token', action.token);
    case COMPOSE_SUGGESTION_SELECT:
      return insertSuggestion(state, action.position, action.token, action.completion);
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
