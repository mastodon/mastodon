import {
  COMPOSE_ENQUETE_CHANGE,
  COMPOSE_ENQUETE_TEXT_CHANGE,
  COMPOSE_ENQUETE_DURATION_CHANGE,
} from '../actions/enquetes';
import {
  COMPOSE_SUBMIT_SUCCESS,
} from '../actions/compose';
import Immutable from 'immutable';

const defaultItems = Immutable.List(['', '', '', '']);
const initialState = Immutable.Map({
  active: false,
  items: defaultItems,
  duration: '30',
});

export default function enquetes(state = initialState, action) {
  switch(action.type) {
  case COMPOSE_ENQUETE_CHANGE:
    return state.withMutations(map => {
      map.set('active', !state.get('active'));
      map.set('items', defaultItems);
    });
  case COMPOSE_ENQUETE_TEXT_CHANGE:
    return state.setIn(['items', action.item_index], action.text);
  case COMPOSE_ENQUETE_DURATION_CHANGE:
    return state.set('duration', action.duration);
  case COMPOSE_SUBMIT_SUCCESS:
    return initialState;
  default:
    return state;
  }
};