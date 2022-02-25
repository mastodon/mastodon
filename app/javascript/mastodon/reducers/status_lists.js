import {
  FAVOURITED_STATUSES_FETCH_REQUEST,
  FAVOURITED_STATUSES_FETCH_SUCCESS,
  FAVOURITED_STATUSES_FETCH_FAIL,
  FAVOURITED_STATUSES_EXPAND_REQUEST,
  FAVOURITED_STATUSES_EXPAND_SUCCESS,
  FAVOURITED_STATUSES_EXPAND_FAIL,
} from '../actions/favourites';
import {
  BOOKMARKED_STATUSES_FETCH_REQUEST,
  BOOKMARKED_STATUSES_FETCH_SUCCESS,
  BOOKMARKED_STATUSES_FETCH_FAIL,
  BOOKMARKED_STATUSES_EXPAND_REQUEST,
  BOOKMARKED_STATUSES_EXPAND_SUCCESS,
  BOOKMARKED_STATUSES_EXPAND_FAIL,
} from '../actions/bookmarks';
import {
  PINNED_STATUSES_FETCH_SUCCESS,
} from '../actions/pin_statuses';
import {
  TRENDS_STATUSES_FETCH_REQUEST,
  TRENDS_STATUSES_FETCH_SUCCESS,
  TRENDS_STATUSES_FETCH_FAIL,
} from '../actions/trends';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS,
  BOOKMARK_SUCCESS,
  UNBOOKMARK_SUCCESS,
  PIN_SUCCESS,
  UNPIN_SUCCESS,
} from '../actions/interactions';
import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
} from '../actions/accounts';

const initialState = ImmutableMap({
  favourites: ImmutableMap({
    next: null,
    loaded: false,
    items: ImmutableList(),
  }),
  bookmarks: ImmutableMap({
    next: null,
    loaded: false,
    items: ImmutableList(),
  }),
  pins: ImmutableMap({
    next: null,
    loaded: false,
    items: ImmutableList(),
  }),
  trending: ImmutableMap({
    next: null,
    loaded: false,
    items: ImmutableList(),
  }),
});

const normalizeList = (state, listType, statuses, next) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('next', next);
    map.set('loaded', true);
    map.set('isLoading', false);
    map.set('items', ImmutableList(statuses.map(item => item.id)));
  }));
};

const appendToList = (state, listType, statuses, next) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('next', next);
    map.set('isLoading', false);
    map.set('items', map.get('items').concat(statuses.map(item => item.id)));
  }));
};

const prependOneToList = (state, listType, status) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('items', map.get('items').unshift(status.get('id')));
  }));
};

const removeOneFromList = (state, listType, status) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('items', map.get('items').filter(item => item !== status.get('id')));
  }));
};

export default function statusLists(state = initialState, action) {
  switch(action.type) {
  case FAVOURITED_STATUSES_FETCH_REQUEST:
  case FAVOURITED_STATUSES_EXPAND_REQUEST:
    return state.setIn(['favourites', 'isLoading'], true);
  case FAVOURITED_STATUSES_FETCH_FAIL:
  case FAVOURITED_STATUSES_EXPAND_FAIL:
    return state.setIn(['favourites', 'isLoading'], false);
  case FAVOURITED_STATUSES_FETCH_SUCCESS:
    return normalizeList(state, 'favourites', action.statuses, action.next);
  case FAVOURITED_STATUSES_EXPAND_SUCCESS:
    return appendToList(state, 'favourites', action.statuses, action.next);
  case BOOKMARKED_STATUSES_FETCH_REQUEST:
  case BOOKMARKED_STATUSES_EXPAND_REQUEST:
    return state.setIn(['bookmarks', 'isLoading'], true);
  case BOOKMARKED_STATUSES_FETCH_FAIL:
  case BOOKMARKED_STATUSES_EXPAND_FAIL:
    return state.setIn(['bookmarks', 'isLoading'], false);
  case BOOKMARKED_STATUSES_FETCH_SUCCESS:
    return normalizeList(state, 'bookmarks', action.statuses, action.next);
  case BOOKMARKED_STATUSES_EXPAND_SUCCESS:
    return appendToList(state, 'bookmarks', action.statuses, action.next);
  case TRENDS_STATUSES_FETCH_REQUEST:
    return state.setIn(['trending', 'isLoading'], true);
  case TRENDS_STATUSES_FETCH_FAIL:
    return state.setIn(['trending', 'isLoading'], false);
  case TRENDS_STATUSES_FETCH_SUCCESS:
    return normalizeList(state, 'trending', action.statuses, action.next);
  case FAVOURITE_SUCCESS:
    return prependOneToList(state, 'favourites', action.status);
  case UNFAVOURITE_SUCCESS:
    return removeOneFromList(state, 'favourites', action.status);
  case BOOKMARK_SUCCESS:
    return prependOneToList(state, 'bookmarks', action.status);
  case UNBOOKMARK_SUCCESS:
    return removeOneFromList(state, 'bookmarks', action.status);
  case PINNED_STATUSES_FETCH_SUCCESS:
    return normalizeList(state, 'pins', action.statuses, action.next);
  case PIN_SUCCESS:
    return prependOneToList(state, 'pins', action.status);
  case UNPIN_SUCCESS:
    return removeOneFromList(state, 'pins', action.status);
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return state.updateIn(['trending', 'items'], ImmutableList(), list => list.filterNot(statusId => action.statuses.getIn([statusId, 'account']) === action.relationship.id));
  default:
    return state;
  }
};
