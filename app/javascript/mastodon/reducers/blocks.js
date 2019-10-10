import Immutable from 'immutable';

import {
  BLOCKS_INIT_MODAL,
} from '../actions/blocks';

const initialState = Immutable.Map({
  new: Immutable.Map({
    account_id: null,
  }),
});

export default function mutes(state = initialState, action) {
  switch (action.type) {
  case BLOCKS_INIT_MODAL:
    return state.withMutations((state) => {
      state.setIn(['new', 'account_id'], action.account.get('id'));
    });
  default:
    return state;
  }
}
