import { SERVER_FETCH_REQUEST, SERVER_FETCH_SUCCESS, SERVER_FETCH_FAIL } from 'mastodon/actions/server';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap({
  isLoading: true,
});

export default function server(state = initialState, action) {
  switch (action.type) {
  case SERVER_FETCH_REQUEST:
    return state.set('isLoading', true);
  case SERVER_FETCH_SUCCESS:
    return fromJS(action.server).set('isLoading', false);
  case SERVER_FETCH_FAIL:
    return state.set('isLoading', false);
  default:
    return state;
  }
}
