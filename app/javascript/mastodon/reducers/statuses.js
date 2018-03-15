import {
  REBLOG_REQUEST,
  REBLOG_SUCCESS,
  REBLOG_FAIL,
  UNREBLOG_SUCCESS,
  FAVOURITE_REQUEST,
  FAVOURITE_SUCCESS,
  FAVOURITE_FAIL,
  UNFAVOURITE_SUCCESS,
  PIN_SUCCESS,
  UNPIN_SUCCESS,
} from '../actions/interactions';
import {
  STATUS_FETCH_SUCCESS,
  CONTEXT_FETCH_SUCCESS,
  STATUS_MUTE_SUCCESS,
  STATUS_UNMUTE_SUCCESS,
  STATUS_REVEAL,
  STATUS_HIDE,
} from '../actions/statuses';
import {
  TIMELINE_REFRESH_SUCCESS,
  TIMELINE_UPDATE,
  TIMELINE_DELETE,
  TIMELINE_EXPAND_SUCCESS,
} from '../actions/timelines';
import {
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_REFRESH_SUCCESS,
  NOTIFICATIONS_EXPAND_SUCCESS,
} from '../actions/notifications';
import {
  FAVOURITED_STATUSES_FETCH_SUCCESS,
  FAVOURITED_STATUSES_EXPAND_SUCCESS,
} from '../actions/favourites';
import {
  PINNED_STATUSES_FETCH_SUCCESS,
} from '../actions/pin_statuses';
import { SEARCH_FETCH_SUCCESS } from '../actions/search';
import emojify from '../features/emoji/emoji';
import { Map as ImmutableMap, fromJS } from 'immutable';
import escapeTextContentForBrowser from 'escape-html';

const domParser = new DOMParser();

const normalizeStatus = (state, status) => {
  if (!status) {
    return state;
  }

  const normalStatus   = { ...status };
  normalStatus.account = status.account.id;

  if (status.reblog && status.reblog.id) {
    state               = normalizeStatus(state, status.reblog);
    normalStatus.reblog = status.reblog.id;
  }

  // Only calculate these values when status first encountered
  // Otherwise keep the ones already in the reducer
  if (!state.has(status.id)) {
    const searchContent = [status.spoiler_text, status.content].join('\n\n').replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');

    const emojiMap = normalStatus.emojis.reduce((obj, emoji) => {
      obj[`:${emoji.shortcode}:`] = emoji;
      return obj;
    }, {});

    normalStatus.search_index = domParser.parseFromString(searchContent, 'text/html').documentElement.textContent;
    normalStatus.contentHtml  = emojify(normalStatus.content, emojiMap);
    normalStatus.spoilerHtml  = emojify(escapeTextContentForBrowser(normalStatus.spoiler_text || ''), emojiMap);
    normalStatus.hidden       = normalStatus.sensitive;
  }

  return state.update(status.id, ImmutableMap(), map => map.mergeDeep(fromJS(normalStatus)));
};

const normalizeStatuses = (state, statuses) => {
  statuses.forEach(status => {
    state = normalizeStatus(state, status);
  });

  return state;
};

const deleteStatus = (state, id, references) => {
  references.forEach(ref => {
    state = deleteStatus(state, ref[0], []);
  });

  return state.delete(id);
};

const initialState = ImmutableMap();

export default function statuses(state = initialState, action) {
  switch(action.type) {
  case TIMELINE_UPDATE:
  case STATUS_FETCH_SUCCESS:
  case NOTIFICATIONS_UPDATE:
    return normalizeStatus(state, action.status);
  case REBLOG_SUCCESS:
  case UNREBLOG_SUCCESS:
  case FAVOURITE_SUCCESS:
  case UNFAVOURITE_SUCCESS:
  case PIN_SUCCESS:
  case UNPIN_SUCCESS:
    return normalizeStatus(state, action.response);
  case FAVOURITE_REQUEST:
    return state.setIn([action.status.get('id'), 'favourited'], true);
  case FAVOURITE_FAIL:
    return state.setIn([action.status.get('id'), 'favourited'], false);
  case REBLOG_REQUEST:
    return state.setIn([action.status.get('id'), 'reblogged'], true);
  case REBLOG_FAIL:
    return state.setIn([action.status.get('id'), 'reblogged'], false);
  case STATUS_MUTE_SUCCESS:
    return state.setIn([action.id, 'muted'], true);
  case STATUS_UNMUTE_SUCCESS:
    return state.setIn([action.id, 'muted'], false);
  case STATUS_REVEAL:
    return state.withMutations(map => {
      action.ids.forEach(id => map.setIn([id, 'hidden'], false));
    });
  case STATUS_HIDE:
    return state.withMutations(map => {
      action.ids.forEach(id => map.setIn([id, 'hidden'], true));
    });
  case TIMELINE_REFRESH_SUCCESS:
  case TIMELINE_EXPAND_SUCCESS:
  case CONTEXT_FETCH_SUCCESS:
  case NOTIFICATIONS_REFRESH_SUCCESS:
  case NOTIFICATIONS_EXPAND_SUCCESS:
  case FAVOURITED_STATUSES_FETCH_SUCCESS:
  case FAVOURITED_STATUSES_EXPAND_SUCCESS:
  case PINNED_STATUSES_FETCH_SUCCESS:
  case SEARCH_FETCH_SUCCESS:
    return normalizeStatuses(state, action.statuses);
  case TIMELINE_DELETE:
    return deleteStatus(state, action.id, action.references);
  default:
    return state;
  }
};
