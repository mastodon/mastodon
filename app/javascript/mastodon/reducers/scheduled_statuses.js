import { Map as ImmutableMap, OrderedSet as ImmutableOrderedSet, fromJS } from 'immutable';

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
} from 'mastodon/actions/scheduled_statuses';

const initialState = ImmutableMap({
  next: null,
  loaded: false,
  isLoading: false,
  updating: ImmutableMap(),
  deleting: ImmutableMap(),
  items: ImmutableOrderedSet(),
  statuses: ImmutableMap(),
});

const normalizeList = (state, statuses, next) => state.withMutations(map => {
  map.set('next', next);
  map.set('loaded', true);
  map.set('isLoading', false);
  map.set('items', ImmutableOrderedSet(statuses.map(item => item.id)));
  map.set('statuses', ImmutableMap(statuses.map(item => [item.id, fromJS(item)])));
});

const appendToList = (state, statuses, next) => state.withMutations(map => {
  map.set('next', next);
  map.set('isLoading', false);
  map.update('items', items => items.union(statuses.map(item => item.id)));
  statuses.forEach(item => map.setIn(['statuses', item.id], fromJS(item)));
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
    return normalizeList(state, action.statuses, action.next);
  case SCHEDULED_STATUSES_EXPAND_SUCCESS:
    return appendToList(state, action.statuses, action.next);
  case SCHEDULED_STATUS_UPDATE_REQUEST:
    return state.setIn(['updating', action.id], true);
  case SCHEDULED_STATUS_UPDATE_FAIL:
    return state.deleteIn(['updating', action.id]);
  case SCHEDULED_STATUS_UPDATE_SUCCESS:
    return state
      .deleteIn(['updating', action.status.id])
      .setIn(['statuses', action.status.id], fromJS(action.status));
  case SCHEDULED_STATUS_DELETE_REQUEST:
    return state.setIn(['deleting', action.id], true);
  case SCHEDULED_STATUS_DELETE_FAIL:
    return state.deleteIn(['deleting', action.id]);
  case SCHEDULED_STATUS_DELETE_SUCCESS:
    return state.withMutations(map => {
      map.deleteIn(['deleting', action.id]);
      map.deleteIn(['statuses', action.id]);
      map.update('items', items => items.delete(action.id));
    });
  default:
    return state;
  }
}
