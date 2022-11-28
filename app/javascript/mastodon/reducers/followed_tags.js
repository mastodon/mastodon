import {
  FOLLOWED_HASHTAGS_FETCH_REQUEST,
  FOLLOWED_HASHTAGS_FETCH_SUCCESS,
  FOLLOWED_HASHTAGS_FETCH_FAIL
} from 'mastodon/actions/tags';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialState = ImmutableMap({
  followed_tags: ImmutableMap({
    items: ImmutableList(),
    isLoading: false,
  }),
});

export default function followed_tags(state = initialState, action) {
  switch(action.type) {
  case FOLLOWED_HASHTAGS_FETCH_REQUEST:
    return state.setIn(['followed_tags', 'isLoading'], true);
  case FOLLOWED_HASHTAGS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.setIn(['followed_tags', 'items'], fromJS(action.followed_tags));
      map.setIn(['followed_tags', 'isLoading'], false);
    });
  case FOLLOWED_HASHTAGS_FETCH_FAIL:
    return state.setIn(['followed_tags', 'isLoading'], false);
  default:
    return state;
  }
};
