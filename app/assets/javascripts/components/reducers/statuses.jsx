import {
  REBLOG_REQUEST,
  REBLOG_SUCCESS,
  REBLOG_FAIL,
  UNREBLOG_SUCCESS,
  FAVOURITE_REQUEST,
  FAVOURITE_SUCCESS,
  FAVOURITE_FAIL,
  UNFAVOURITE_SUCCESS
} from '../actions/interactions';
import {
  STATUS_FETCH_SUCCESS,
  CONTEXT_FETCH_SUCCESS
} from '../actions/statuses';
import {
  TIMELINE_REFRESH_SUCCESS,
  TIMELINE_UPDATE,
  TIMELINE_DELETE,
  TIMELINE_EXPAND_SUCCESS
} from '../actions/timelines';
import {
  ACCOUNT_TIMELINE_FETCH_SUCCESS,
  ACCOUNT_TIMELINE_EXPAND_SUCCESS,
  ACCOUNT_BLOCK_SUCCESS
} from '../actions/accounts';
import {
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_REFRESH_SUCCESS,
  NOTIFICATIONS_EXPAND_SUCCESS
} from '../actions/notifications';
import {
  FAVOURITED_STATUSES_FETCH_SUCCESS,
  FAVOURITED_STATUSES_EXPAND_SUCCESS
} from '../actions/favourites';
import { SEARCH_FETCH_SUCCESS } from '../actions/search';
import Immutable from 'immutable';

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

  const linebreakComplemented = status.content.replace(/<br \/>/g, '\n').replace(/<\/p><p>/g, '\n\n');
  normalStatus.unescaped_content = new DOMParser().parseFromString(linebreakComplemented, 'text/html').documentElement.textContent;

  return state.update(status.id, Immutable.Map(), map => map.mergeDeep(Immutable.fromJS(normalStatus)));
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

const filterStatuses = (state, relationship) => {
  state.forEach(status => {
    if (status.get('account') !== relationship.id) {
      return;
    }

    state = deleteStatus(state, status.get('id'), state.filter(item => item.get('reblog') === status.get('id')));
  });

  return state;
};

const initialState = Immutable.Map();

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
    return normalizeStatus(state, action.response);
  case FAVOURITE_REQUEST:
    return state.setIn([action.status.get('id'), 'favourited'], true);
  case FAVOURITE_FAIL:
    return state.setIn([action.status.get('id'), 'favourited'], false);
  case REBLOG_REQUEST:
    return state.setIn([action.status.get('id'), 'reblogged'], true);
  case REBLOG_FAIL:
    return state.setIn([action.status.get('id'), 'reblogged'], false);
  case TIMELINE_REFRESH_SUCCESS:
  case TIMELINE_EXPAND_SUCCESS:
  case ACCOUNT_TIMELINE_FETCH_SUCCESS:
  case ACCOUNT_TIMELINE_EXPAND_SUCCESS:
  case CONTEXT_FETCH_SUCCESS:
  case NOTIFICATIONS_REFRESH_SUCCESS:
  case NOTIFICATIONS_EXPAND_SUCCESS:
  case FAVOURITED_STATUSES_FETCH_SUCCESS:
  case FAVOURITED_STATUSES_EXPAND_SUCCESS:
  case SEARCH_FETCH_SUCCESS:
    return normalizeStatuses(state, action.statuses);
  case TIMELINE_DELETE:
    return deleteStatus(state, action.id, action.references);
  case ACCOUNT_BLOCK_SUCCESS:
    return filterStatuses(state, action.relationship);
  default:
    return state;
  }
};
