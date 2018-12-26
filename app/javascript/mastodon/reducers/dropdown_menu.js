import Immutable from 'immutable';
import {
  DROPDOWN_MENU_OPEN,
  DROPDOWN_MENU_CLOSE,
} from '../actions/dropdown_menu';

const initialState = Immutable.Map({ openId: null, placement: null, keyboard: false });

export default function dropdownMenu(state = initialState, action) {
  switch (action.type) {
  case DROPDOWN_MENU_OPEN:
    return state.merge({ openId: action.id, placement: action.placement, keyboard: action.keyboard });
  case DROPDOWN_MENU_CLOSE:
    return state.get('openId') === action.id ? state.set('openId', null) : state;
  default:
    return state;
  }
}
