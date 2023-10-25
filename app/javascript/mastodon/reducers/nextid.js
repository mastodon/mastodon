import { Map as ImmutableMap } from 'immutable';

import { NEXTID_SAVE_POST_FAIL, NEXTID_SAVE_POST_REQUEST, NEXTID_SAVE_POST_SUCCESS } from 'mastodon/actions/nextid';

const initialState = ImmutableMap({
  submitted: false,
  isLoading: false,
});

export default function nextid(state = initialState, action) {
  switch (action.type) {
  case NEXTID_SAVE_POST_REQUEST:
    return state.withMutations(map => {
      map.set('submitted', true);
      map.set('isLoading', true);
    });
  case NEXTID_SAVE_POST_SUCCESS:
    return state.withMutations(map => {
      map.set('submitted', false);
      map.set('isLoading', false);
    });
  case NEXTID_SAVE_POST_FAIL:
    return state.withMutations(map => {
      map.set('submitted', false);
      map.set('isLoading', false);
    });
  }
  return state;
}
