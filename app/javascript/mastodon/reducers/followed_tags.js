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
  followed_tags: ImmutableMap({
    items: ImmutableList(),
    isLoading: false,
    next: null
  }),
});

export default function followed_tags(state = initialState, action) {
  switch(action.type) {
  case FOLLOWED_HASHTAGS_FETCH_REQUEST:
    return state.setIn(['isLoading'], true);
  case FOLLOWED_HASHTAGS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.setIn(['items'], fromJS(action.followed_tags));
      map.setIn(['isLoading'], false);
      map.setIn(['next'], action.next);
    });
  case FOLLOWED_HASHTAGS_FETCH_FAIL:
    return state.setIn(['isLoading'], false);
  case FOLLOWED_HASHTAGS_EXPAND_REQUEST:
    return state.setIn(['isLoading'], true);
  case FOLLOWED_HASHTAGS_EXPAND_SUCCESS:
    return state.withMutations(map => {
      map.updateIn(['items'], set => set.concat(fromJS(action.followed_tags)));
      map.setIn(['isLoading'], false);
      map.setIn(['next'], action.next);
    });
  case FOLLOWED_HASHTAGS_EXPAND_FAIL:
    return state.setIn(['isLoading'], false);
  default:
    return state;
  }
};
