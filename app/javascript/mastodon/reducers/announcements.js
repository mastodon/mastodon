import {
  ANNOUNCEMENTS_FETCH_REQUEST,
  ANNOUNCEMENTS_FETCH_SUCCESS,
  ANNOUNCEMENTS_FETCH_FAIL,
  ANNOUNCEMENTS_UPDATE,
  ANNOUNCEMENTS_DISMISS,
} from '../actions/announcements';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
});

export default function announcementsReducer(state = initialState, action) {
  switch(action.type) {
  case ANNOUNCEMENTS_FETCH_REQUEST:
    return state.set('isLoading', true);
  case ANNOUNCEMENTS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('items', fromJS(action.announcements));
      map.set('isLoading', false);
    });
  case ANNOUNCEMENTS_FETCH_FAIL:
    return state.set('isLoading', false);
  case ANNOUNCEMENTS_UPDATE:
    return state.update('items', list => list.unshift(fromJS(action.announcement)).sortBy(x => x.get('starts_at')));
  case ANNOUNCEMENTS_DISMISS:
    return state.update('items', list => list.filterNot(x => x.get('id') === action.id));
  default:
    return state;
  }
};
