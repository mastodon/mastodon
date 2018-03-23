import { STATUS_CARD_FETCH_SUCCESS } from '../actions/cards';

import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap();

export default function cards(state = initialState, action) {
  switch(action.type) {
  case STATUS_CARD_FETCH_SUCCESS:
    return state.set(action.id, fromJS(action.card));
  default:
    return state;
  }
};
