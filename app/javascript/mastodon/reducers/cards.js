import { STATUS_CARD_FETCH_SUCCESS } from '../actions/cards';

import Immutable from 'immutable';

const initialState = Immutable.Map();

export default function cards(state = initialState, action) {
  switch(action.type) {
  case STATUS_CARD_FETCH_SUCCESS:
    return state.set(action.id, Immutable.fromJS(action.card));
  default:
    return state;
  }
};
