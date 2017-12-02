import {
  LIST_FETCH_SUCCESS,
  LISTS_FETCH_SUCCESS,
  LIST_CREATE_SUCCESS,
  LIST_UPDATE_SUCCESS,
} from '../actions/lists';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap();

const normalizeList = (state, list) => state.set(list.id, fromJS(list));

const normalizeLists = (state, lists) => {
  lists.forEach(list => {
    state = normalizeList(state, list);
  });

  return state;
};

export default function lists(state = initialState, action) {
  switch(action.type) {
  case LIST_FETCH_SUCCESS:
  case LIST_CREATE_SUCCESS:
  case LIST_UPDATE_SUCCESS:
    return normalizeList(state, action.list);
  case LISTS_FETCH_SUCCESS:
    return normalizeLists(state, action.lists);
  default:
    return state;
  }
};
