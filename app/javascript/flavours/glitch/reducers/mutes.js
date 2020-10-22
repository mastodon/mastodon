import Immutable from 'immutable';

import {
  MUTES_INIT_MODAL,
  MUTES_TOGGLE_HIDE_NOTIFICATIONS,
  MUTES_CHANGE_DURATION,
} from 'flavours/glitch/actions/mutes';

const initialState = Immutable.Map({
  new: Immutable.Map({
    account: null,
    notifications: true,
    duration: 0,
  }),
});

export default function mutes(state = initialState, action) {
  switch (action.type) {
  case MUTES_INIT_MODAL:
    return state.withMutations((state) => {
      state.setIn(['new', 'account'], action.account);
      state.setIn(['new', 'notifications'], true);
    });
  case MUTES_TOGGLE_HIDE_NOTIFICATIONS:
    return state.updateIn(['new', 'notifications'], (old) => !old);
  case MUTES_CHANGE_DURATION:
    return state.setIn(['new', 'duration'], Number(action.duration));
  default:
    return state;
  }
}
