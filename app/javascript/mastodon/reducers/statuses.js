import { Map as ImmutableMap, fromJS } from 'immutable';

import { timelineDelete } from 'mastodon/actions/timelines_typed';

import { STATUS_IMPORT, STATUSES_IMPORT } from '../actions/importer';
import { normalizeStatusTranslation } from '../actions/importer/normalizer';
import {
  FAVOURITE_REQUEST,
  FAVOURITE_FAIL,
  UNFAVOURITE_REQUEST,
  UNFAVOURITE_FAIL,
  BOOKMARK_REQUEST,
  BOOKMARK_FAIL,
  UNBOOKMARK_REQUEST,
  UNBOOKMARK_FAIL,
} from '../actions/interactions';
import {
  reblog,
  unreblog,
} from '../actions/interactions_typed';
import {
  STATUS_MUTE_SUCCESS,
  STATUS_UNMUTE_SUCCESS,
  STATUS_REVEAL,
  STATUS_HIDE,
  STATUS_COLLAPSE,
  STATUS_TRANSLATE_SUCCESS,
  STATUS_TRANSLATE_UNDO,
  STATUS_FETCH_REQUEST,
  STATUS_FETCH_FAIL,
} from '../actions/statuses';

const importStatus = (state, status) => state.set(status.id, fromJS(status));

const importStatuses = (state, statuses) =>
  state.withMutations(mutable => statuses.forEach(status => importStatus(mutable, status)));

const deleteStatus = (state, id, references) => {
  references.forEach(ref => {
    state = deleteStatus(state, ref, []);
  });

  return state.delete(id);
};

const statusTranslateSuccess = (state, id, translation) => {
  return state.withMutations(map => {
    map.setIn([id, 'translation'], fromJS(normalizeStatusTranslation(translation, map.get(id))));

    const list = map.getIn([id, 'media_attachments']);
    if (translation.media_attachments && list) {
      translation.media_attachments.forEach(item => {
        const index = list.findIndex(i => i.get('id') === item.id);
        map.setIn([id, 'media_attachments', index, 'translation'], fromJS({ description: item.description }));
      });
    }
  });
};

const statusTranslateUndo = (state, id) => {
  return state.withMutations(map => {
    map.deleteIn([id, 'translation']);
    map.getIn([id, 'media_attachments']).forEach((item, index) => map.deleteIn([id, 'media_attachments', index, 'translation']));
  });
};

const initialState = ImmutableMap();

/** @type {import('@reduxjs/toolkit').Reducer<typeof initialState>} */
export default function statuses(state = initialState, action) {
  switch(action.type) {
  case STATUS_FETCH_REQUEST:
    return state.setIn([action.id, 'isLoading'], true);
  case STATUS_FETCH_FAIL:
    return state.delete(action.id);
  case STATUS_IMPORT:
    return importStatus(state, action.status);
  case STATUSES_IMPORT:
    return importStatuses(state, action.statuses);
  case FAVOURITE_REQUEST:
    return state.setIn([action.status.get('id'), 'favourited'], true);
  case FAVOURITE_FAIL:
    return state.get(action.status.get('id')) === undefined ? state : state.setIn([action.status.get('id'), 'favourited'], false);
  case UNFAVOURITE_REQUEST:
    return state.setIn([action.status.get('id'), 'favourited'], false);
  case UNFAVOURITE_FAIL:
    return state.get(action.status.get('id')) === undefined ? state : state.setIn([action.status.get('id'), 'favourited'], true);
  case BOOKMARK_REQUEST:
    return state.get(action.status.get('id')) === undefined ? state : state.setIn([action.status.get('id'), 'bookmarked'], true);
  case BOOKMARK_FAIL:
    return state.get(action.status.get('id')) === undefined ? state : state.setIn([action.status.get('id'), 'bookmarked'], false);
  case UNBOOKMARK_REQUEST:
    return state.get(action.status.get('id')) === undefined ? state : state.setIn([action.status.get('id'), 'bookmarked'], false);
  case UNBOOKMARK_FAIL:
    return state.get(action.status.get('id')) === undefined ? state : state.setIn([action.status.get('id'), 'bookmarked'], true);
  case STATUS_MUTE_SUCCESS:
    return state.setIn([action.id, 'muted'], true);
  case STATUS_UNMUTE_SUCCESS:
    return state.setIn([action.id, 'muted'], false);
  case STATUS_REVEAL:
    return state.withMutations(map => {
      action.ids.forEach(id => {
        if (!(state.get(id) === undefined)) {
          map.setIn([id, 'hidden'], false);
        }
      });
    });
  case STATUS_HIDE:
    return state.withMutations(map => {
      action.ids.forEach(id => {
        if (!(state.get(id) === undefined)) {
          map.setIn([id, 'hidden'], true);
        }
      });
    });
  case STATUS_COLLAPSE:
    return state.setIn([action.id, 'collapsed'], action.isCollapsed);
  case timelineDelete.type:
    return deleteStatus(state, action.payload.statusId, action.payload.references);
  case STATUS_TRANSLATE_SUCCESS:
    return statusTranslateSuccess(state, action.id, action.translation);
  case STATUS_TRANSLATE_UNDO:
    return statusTranslateUndo(state, action.id);
  default:
    if(reblog.pending.match(action))
      return state.setIn([action.meta.arg.statusId, 'reblogged'], true);
    else if(reblog.rejected.match(action))
      return state.get(action.meta.arg.statusId) === undefined ? state : state.setIn([action.meta.arg.statusId, 'reblogged'], false);
    else if(unreblog.pending.match(action))
      return state.setIn([action.meta.arg.statusId, 'reblogged'], false);
    else if(unreblog.rejected.match(action))
      return state.get(action.meta.arg.statusId) === undefined ? state : state.setIn([action.meta.arg.statusId, 'reblogged'], true);
    else
      return state;
  }
}
