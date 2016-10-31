import {
  REBLOG_SUCCESS,
  UNREBLOG_SUCCESS,
  FAVOURITE_SUCCESS,
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
  ACCOUNT_TIMELINE_EXPAND_SUCCESS
} from '../actions/accounts';
import Immutable from 'immutable';

const normalizeStatus = (state, status) => {
  status = status.set('account', status.getIn(['account', 'id']));

  if (status.getIn(['reblog', 'id'])) {
    state  = normalizeStatus(state, status.get('reblog'));
    status = status.set('reblog', status.getIn(['reblog', 'id']));
  }

  return state.set(status.get('id'), status);
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

const initialState = Immutable.Map();

export default function statuses(state = initialState, action) {
  switch(action.type) {
    case TIMELINE_UPDATE:
    case STATUS_FETCH_SUCCESS:
    case REBLOG_SUCCESS:
    case UNREBLOG_SUCCESS:
    case FAVOURITE_SUCCESS:
    case UNFAVOURITE_SUCCESS:
      return normalizeStatus(state, Immutable.fromJS(action.status));
    case TIMELINE_REFRESH_SUCCESS:
    case TIMELINE_EXPAND_SUCCESS:
    case ACCOUNT_TIMELINE_FETCH_SUCCESS:
    case ACCOUNT_TIMELINE_EXPAND_SUCCESS:
    case CONTEXT_FETCH_SUCCESS:
      return normalizeStatuses(state, Immutable.fromJS(action.statuses));
    case TIMELINE_DELETE:
      return deleteStatus(state, action.id, action.references);
    default:
      return state;
  }
};
