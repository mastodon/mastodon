import {
  INSTANCE_STATS_FETCH_REQUEST,
  INSTNACE_STATS_FETCH_SUCCESS,
  INSTNACE_STATS_FETCH_FAIL,
} from 'mastodon/actions/instance_stats';
import { Map as ImmutableMap, fromJS } from 'immutable';

const initialState = ImmutableMap({
  instance_stats: ImmutableMap({
    isLoading: true,
  }),
});

export default function instance_stats(state = initialState, action) {
  switch (action.type) {
  case INSTANCE_STATS_FETCH_REQUEST:
    return state.setIn(['instance_stats', 'isLoading'], true);
  case INSTNACE_STATS_FETCH_SUCCESS:
    return state.setIn(['instance_stats', 'instance_stats'], fromJS(action.data)).setIn(['instance_stats', 'isLoading'], false);
  case INSTNACE_STATS_FETCH_FAIL:
    return state.setIn(['instance_stats', 'isLoading'], false);
  default:
    return state;
  }
}
