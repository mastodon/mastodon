import { Map as ImmutableMap, OrderedMap as ImmutableOrderedMap, fromJS } from 'immutable';

import {
  SCHEDULED_STATUSES_FETCH_REQUEST,
  SCHEDULED_STATUSES_FETCH_SUCCESS,
  SCHEDULED_STATUSES_FETCH_FAIL,
  SCHEDULED_STATUSES_EXPAND_REQUEST,
  SCHEDULED_STATUSES_EXPAND_SUCCESS,
  SCHEDULED_STATUSES_EXPAND_FAIL,
  SCHEDULED_STATUS_CREATE_SUCCESS,
  SCHEDULED_STATUS_UPDATE_SUCCESS,
  SCHEDULED_STATUS_CANCEL_SUCCESS,
} from '../actions/scheduled_statuses';

const initialState = ImmutableMap({
  next: null,
  loaded: false,
  isLoading: false,
  items: ImmutableOrderedMap(),
});

const normalizeStatuses = (statuses) => ImmutableOrderedMap(
  statuses.map(status => [status.id, fromJS(status)])
);

const prependStatus = (state, status) => state.update('items', items => {
  if (items.has(status.id)) {
    return items.set(status.id, fromJS(status));
  }

  return ImmutableOrderedMap([[status.id, fromJS(status)]]).merge(items);
});

export default function scheduledStatuses(state = initialState, action) {
  switch(action.type) {
  case SCHEDULED_STATUSES_FETCH_REQUEST:
  case SCHEDULED_STATUSES_EXPAND_REQUEST:
    return state.set('isLoading', true);
  case SCHEDULED_STATUSES_FETCH_FAIL:
  case SCHEDULED_STATUSES_EXPAND_FAIL:
    return state.set('isLoading', false);
  case SCHEDULED_STATUSES_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('next', action.next);
      map.set('loaded', true);
      map.set('isLoading', false);
      map.set('items', normalizeStatuses(action.statuses));
    });
  case SCHEDULED_STATUSES_EXPAND_SUCCESS:
    return state.withMutations(map => {
      map.set('next', action.next);
      map.set('isLoading', false);
      map.update('items', items => items.merge(normalizeStatuses(action.statuses)));
    });
  case SCHEDULED_STATUS_CREATE_SUCCESS:
    return prependStatus(state, action.status);
  case SCHEDULED_STATUS_UPDATE_SUCCESS:
    return state
      .set('isLoading', false)
      .setIn(['items', action.status.id], fromJS(action.status));
  case SCHEDULED_STATUS_CANCEL_SUCCESS:
    return state
      .set('isLoading', false)
      .deleteIn(['items', action.id]);
  default:
    return state;
  }
}
