import {
  FOLLOWED_HASHTAGS_FETCH_REQUEST,
  FOLLOWED_HASHTAGS_FETCH_SUCCESS,
  FOLLOWED_HASHTAGS_FETCH_FAIL,
  FOLLOWED_HASHTAGS_EXPAND_REQUEST,
  FOLLOWED_HASHTAGS_EXPAND_SUCCESS,
  FOLLOWED_HASHTAGS_EXPAND_FAIL,
} from 'mastodon/actions/tags';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
  next: null,
});

export default function followed_tags(state = initialState, action) {
  switch(action.type) {
  case FOLLOWED_HASHTAGS_FETCH_REQUEST:
    return state.set('isLoading', true);
  case FOLLOWED_HASHTAGS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('items', fromJS(action.followed_tags));
      map.set('isLoading', false);
      map.set('next', action.next);
    });
  case FOLLOWED_HASHTAGS_FETCH_FAIL:
    return state.set('isLoading', false);
  case FOLLOWED_HASHTAGS_EXPAND_REQUEST:
    return state.set('isLoading', true);
  case FOLLOWED_HASHTAGS_EXPAND_SUCCESS:
    return state.withMutations(map => {
      map.update('items', set => set.concat(fromJS(action.followed_tags)));
      map.set('isLoading', false);
      map.set('next', action.next);
    });
  case FOLLOWED_HASHTAGS_EXPAND_FAIL:
    return state.set('isLoading', false);
  default:
    return state;
  }
}
