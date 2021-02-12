import Immutable from 'immutable';

import {
  BOOSTS_INIT_MODAL,
  BOOSTS_CHANGE_PRIVACY,
} from 'flavours/glitch/actions/boosts';

const initialState = Immutable.Map({
  new: Immutable.Map({
    privacy: 'public',
  }),
});

export default function mutes(state = initialState, action) {
  switch (action.type) {
  case BOOSTS_INIT_MODAL:
    return state.withMutations((state) => {
      state.setIn(['new', 'privacy'], action.privacy);
    });
  case BOOSTS_CHANGE_PRIVACY:
    return state.setIn(['new', 'privacy'], action.privacy);
  default:
    return state;
  }
}
