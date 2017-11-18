import { LIST_FETCH_SUCCESS } from '../actions/lists';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap();

const normalizeList = (state, list) => state.set(list.id, fromJS(list));

export default function lists(state = initialState, action) {
  switch(action.type) {
  case LIST_FETCH_SUCCESS:
    return normalizeList(state, action.list);
  default:
    return state;
  }
};
