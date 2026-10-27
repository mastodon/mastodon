import { List as ImmutableList, Map as ImmutableMap, fromJS } from 'immutable';

import { COMPOSE_SUBMIT_SUCCESS } from '../actions/compose';
import {
  SCHEDULED_STATUSES_FETCH_REQUEST,
  SCHEDULED_STATUSES_FETCH_SUCCESS,
  SCHEDULED_STATUSES_FETCH_FAIL,
  SCHEDULED_STATUSES_EXPAND_REQUEST,
  SCHEDULED_STATUSES_EXPAND_SUCCESS,
  SCHEDULED_STATUSES_EXPAND_FAIL,
  SCHEDULED_STATUS_UPDATE_REQUEST,
  SCHEDULED_STATUS_UPDATE_SUCCESS,
  SCHEDULED_STATUS_UPDATE_FAIL,
  SCHEDULED_STATUS_DELETE_REQUEST,
  SCHEDULED_STATUS_DELETE_SUCCESS,
  SCHEDULED_STATUS_DELETE_FAIL,
} from '../actions/scheduled_statuses';

const initialState = ImmutableMap({
  next: null,
  loaded: false,
  isLoading: false,
  items: ImmutableList(),
  updating: ImmutableMap(),
  deleting: ImmutableMap(),
});

const normalizeStatuses = (state, statuses, next) =>
  state.withMutations((map) => {
    map.set('next', next);
    map.set('loaded', true);
    map.set('isLoading', false);
    map.set('items', ImmutableList(statuses.map((status) => fromJS(status))));
  });

const appendStatuses = (state, statuses, next) =>
  state.withMutations((map) => {
    const existingIds = new Set(map.get('items').map((item) => item.get('id')));
    const newItems = statuses
      .filter((status) => !existingIds.has(status.id))
      .map((status) => fromJS(status));

    map.set('next', next);
    map.set('isLoading', false);
    map.update('items', (items) => items.concat(newItems));
  });

const replaceStatus = (state, status) =>
  state.update('items', (items) =>
    items.map((item) =>
      item.get('id') === status.id ? fromJS(status) : item,
    ),
  );

const prependStatus = (state, status) =>
  state.update('items', (items) => {
    const nextItems = items.filter((item) => item.get('id') !== status.id);
    return ImmutableList([fromJS(status)]).concat(nextItems);
  });

const removeStatus = (state, id) =>
  state.update('items', (items) => items.filter((item) => item.get('id') !== id));

/** @type {import('@reduxjs/toolkit').Reducer<typeof initialState>} */
export default function scheduledStatuses(state = initialState, action) {
  switch (action.type) {
  case SCHEDULED_STATUSES_FETCH_REQUEST:
  case SCHEDULED_STATUSES_EXPAND_REQUEST:
    return state.set('isLoading', true);
  case SCHEDULED_STATUSES_FETCH_FAIL:
  case SCHEDULED_STATUSES_EXPAND_FAIL:
    return state.set('isLoading', false);
  case SCHEDULED_STATUSES_FETCH_SUCCESS:
    return normalizeStatuses(state, action.statuses, action.next);
  case SCHEDULED_STATUSES_EXPAND_SUCCESS:
    return appendStatuses(state, action.statuses, action.next);
  case SCHEDULED_STATUS_UPDATE_REQUEST:
    return state.setIn(['updating', action.id], true);
  case SCHEDULED_STATUS_UPDATE_SUCCESS:
    return replaceStatus(state, action.status).deleteIn([
      'updating',
      action.status.id,
    ]);
  case SCHEDULED_STATUS_UPDATE_FAIL:
    return state.deleteIn(['updating', action.id]);
  case SCHEDULED_STATUS_DELETE_REQUEST:
    return state.setIn(['deleting', action.id], true);
  case SCHEDULED_STATUS_DELETE_SUCCESS:
    return removeStatus(state, action.id).deleteIn(['deleting', action.id]);
  case SCHEDULED_STATUS_DELETE_FAIL:
    return state.deleteIn(['deleting', action.id]);
  case COMPOSE_SUBMIT_SUCCESS:
    if (action.status?.scheduled_at) {
      return prependStatus(state, action.status);
    }

    return state;
  default:
    return state;
  }
}
