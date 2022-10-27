import {
  HASHTAG_FETCH_SUCCESS,
  HASHTAG_FOLLOW_REQUEST,
  HASHTAG_FOLLOW_FAIL,
  HASHTAG_UNFOLLOW_REQUEST,
  HASHTAG_UNFOLLOW_FAIL,
} from 'mastodon/actions/tags';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap();

export default function tags(state = initialState, action) {
  switch(action.type) {
  case HASHTAG_FETCH_SUCCESS:
    return state.set(action.name, fromJS(action.tag));
  case HASHTAG_FOLLOW_REQUEST:
  case HASHTAG_UNFOLLOW_FAIL:
    return state.setIn([action.name, 'following'], true);
  case HASHTAG_FOLLOW_FAIL:
  case HASHTAG_UNFOLLOW_REQUEST:
    return state.setIn([action.name, 'following'], false);
  default:
    return state;
  }
};
