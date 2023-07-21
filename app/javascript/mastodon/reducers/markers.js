import { Map as ImmutableMap } from 'immutable';

import {
  MARKERS_SUBMIT_SUCCESS,
} from '../actions/markers';


const initialState = ImmutableMap({
  home: '0',
  notifications: '0',
});

export default function markers(state = initialState, action) {
  switch(action.type) {
  case MARKERS_SUBMIT_SUCCESS:
    if (action.home) {
      state = state.set('home', action.home);
    }
    if (action.notifications) {
      state = state.set('notifications', action.notifications);
    }
    return state;
  default:
    return state;
  }
}
