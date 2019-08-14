import Immutable from 'immutable';

import {
  BLOCKS_INIT_MODAL,
  BLOCKS_TOGGLE_HARD_BLOCK,
} from '../actions/blocks';

const initialState = Immutable.Map({
  new: Immutable.Map({
    account_id: null,
    hard_block: false,
  }),
});

export default function mutes(state = initialState, action) {
  switch (action.type) {
  case BLOCKS_INIT_MODAL:
    return state.withMutations((state) => {
      state.setIn(['new', 'account_id'], action.account.get('id'));
      state.setIn(['new', 'hard_block'], false);
    });
  case BLOCKS_TOGGLE_HARD_BLOCK:
    return state.updateIn(['new', 'hard_block'], (old) => !old);
  default:
    return state;
  }
}
