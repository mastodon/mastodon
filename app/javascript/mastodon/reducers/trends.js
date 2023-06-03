import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

import {
  TRENDS_TAGS_FETCH_REQUEST,
  TRENDS_TAGS_FETCH_SUCCESS,
  TRENDS_TAGS_FETCH_FAIL,
  TRENDS_LINKS_FETCH_REQUEST,
  TRENDS_LINKS_FETCH_SUCCESS,
  TRENDS_LINKS_FETCH_FAIL,
} from 'mastodon/actions/trends';

const initialState = ImmutableMap({
  tags: ImmutableMap({
    items: ImmutableList(),
    isLoading: false,
  }),

  links: ImmutableMap({
    items: ImmutableList(),
    isLoading: false,
  }),
});

export default function trendsReducer(state = initialState, action) {
  switch(action.type) {
  case TRENDS_TAGS_FETCH_REQUEST:
    return state.setIn(['tags', 'isLoading'], true);
  case TRENDS_TAGS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.setIn(['tags', 'items'], fromJS(action.trends));
      map.setIn(['tags', 'isLoading'], false);
    });
  case TRENDS_TAGS_FETCH_FAIL:
    return state.setIn(['tags', 'isLoading'], false);
  case TRENDS_LINKS_FETCH_REQUEST:
    return state.setIn(['links', 'isLoading'], true);
  case TRENDS_LINKS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.setIn(['links', 'items'], fromJS(action.trends));
      map.setIn(['links', 'isLoading'], false);
    });
  case TRENDS_LINKS_FETCH_FAIL:
    return state.setIn(['links', 'isLoading'], false);
  default:
    return state;
  }
}
