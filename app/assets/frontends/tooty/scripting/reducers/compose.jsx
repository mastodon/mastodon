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
  COMPOSE_SPOILERNESS_CHANGE,
  COMPOSE_SPOILER_TEXT_CHANGE,
  COMPOSE_VISIBILITY_CHANGE,
  COMPOSE_LISTABILITY_CHANGE,
  COMPOSE_EMOJI_INSERT
} from '../actions/compose';
import { TIMELINE_DELETE } from '../actions/timelines';
import { STORE_HYDRATE } from '../actions/store';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  mounted: false,
  sensitive: false,
  spoiler: false,
  spoiler_text: '',
  privacy: null,
  text: '',
  focusDate: null,
  preselectDate: null,
  in_reply_to: null,
  is_submitting: false,
  is_uploading: false,
  progress: 0,
  media_attachments: Immutable.List(),
  suggestion_token: null,
  suggestions: Immutable.List(),
  me: null,
  default_privacy: 'public',
  resetFileKey: Math.floor((Math.random() * 0x10000))
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
    map.set('spoiler', false);
    map.set('spoiler_text', '');
    map.set('is_submitting', false);
    map.set('in_reply_to', null);
    map.set('privacy', state.get('default_privacy'));
    map.set('sensitive', false);
    map.update('media_attachments', list => list.clear());
  });
};

function appendMedia(state, media) {
  return state.withMutations(map => {
    map.update('media_attachments', list => list.push(media));
    map.set('is_uploading', false);
    map.set('resetFileKey', Math.floor((Math.random() * 0x10000)));
    map.set('focusDate', new Date());
    map.update('text', oldText => `${oldText.trim()} ${media.get('text_url')}`.trim() + ' ');
  });
};

function removeMedia(state, mediaId) {
  const media    = state.get('media_attachments').find(item => item.get('id') === mediaId);
  const prevSize = state.get('media_attachments').size;

  return state.withMutations(map => {
    map.update('media_attachments', list => list.filterNot(item => item.get('id') === mediaId));
    map.update('text', text => text.replace(media.get('text_url'), '').trim());

    if (prevSize === 1) {
      map.set('sensitive', false);
    }
  });
};

const insertSuggestion = (state, position, token, completion) => {
  return state.withMutations(map => {
    map.update('text', oldText => `${oldText.slice(0, position)}${completion} ${oldText.slice(position + token.length)}`);
    map.set('suggestion_token', null);
    map.update('suggestions', Immutable.List(), list => list.clear());
    map.set('focusDate', new Date());
  });
};

const insertEmoji = (state, position, emojiData) => {
  const emoji = emojiData.shortname;

  return state.withMutations(map => {
    map.update('text', oldText => `${oldText.slice(0, position)}${emoji} ${oldText.slice(position)}`);
    map.set('focusDate', new Date());
  });
};

const privacyPreference = (a, b) => {
  if (a === 'direct' || b === 'direct') {
    return 'direct';
  } else if (a === 'private' || b === 'private') {
    return 'private';
  } else if (a === 'unlisted' || b === 'unlisted') {
    return 'unlisted';
  } else {
    return 'public';
  }
};

export default function compose(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return clearAll(state.merge(action.state.get('compose')));
  case COMPOSE_MOUNT:
    return state.set('mounted', true);
  case COMPOSE_UNMOUNT:
    return state.set('mounted', false);
  case COMPOSE_SENSITIVITY_CHANGE:
    return state.set('sensitive', !state.get('sensitive'));
  case COMPOSE_SPOILERNESS_CHANGE:
    return state.withMutations(map => {
      map.set('spoiler_text', '');
      map.set('spoiler', !state.get('spoiler'));
    });
  case COMPOSE_SPOILER_TEXT_CHANGE:
    return state.set('spoiler_text', action.text);
  case COMPOSE_VISIBILITY_CHANGE:
    return state.set('privacy', action.value);
  case COMPOSE_CHANGE:
    return state.set('text', action.text);
  case COMPOSE_REPLY:
    return state.withMutations(map => {
      map.set('in_reply_to', action.status.get('id'));
      map.set('text', statusToTextMentions(state, action.status));
      map.set('privacy', privacyPreference(action.status.get('visibility'), state.get('default_privacy')));
      map.set('focusDate', new Date());
      map.set('preselectDate', new Date());

      if (action.status.get('spoiler_text').length > 0) {
        map.set('spoiler', true);
        map.set('spoiler_text', action.status.get('spoiler_text'));
      } else {
        map.set('spoiler', false);
        map.set('spoiler_text', '');
      }
    });
  case COMPOSE_REPLY_CANCEL:
    return state.withMutations(map => {
      map.set('in_reply_to', null);
      map.set('text', '');
      map.set('spoiler', false);
      map.set('spoiler_text', '');
      map.set('privacy', state.get('default_privacy'));
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
    return state.update('text', text => `${text}@${action.account.get('acct')} `).set('focusDate', new Date());
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
  case COMPOSE_EMOJI_INSERT:
    return insertEmoji(state, action.position, action.emoji);
  default:
    return state;
  }
};
