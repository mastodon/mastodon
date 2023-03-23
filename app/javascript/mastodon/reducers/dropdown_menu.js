import Immutable from 'immutable';
import {
  DROPDOWN_MENU_OPEN,
  DROPDOWN_MENU_CLOSE,
} from '../actions/dropdown_menu';

const initialState = Immutable.Map({ openId: null, keyboard: false, scroll_key: null });

export default function dropdownMenu(state = initialState, action) {
  switch (action.type) {
  case DROPDOWN_MENU_OPEN:
    return state.merge({ openId: action.id, keyboard: action.keyboard, scroll_key: action.scroll_key });
  case DROPDOWN_MENU_CLOSE:
    return state.get('openId') === action.id ? state.set('openId', null).set('scroll_key', null) : state;
  default:
    return state;
  }
}
