import { HISTORY_FETCH_REQUEST, HISTORY_FETCH_SUCCESS, HISTORY_FETCH_FAIL } from 'mastodon/actions/history';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialState = ImmutableMap({
  loading: false,
  items: ImmutableList(),
});

export default function history(state = initialState, action) {
  switch(action.type) {
  case HISTORY_FETCH_REQUEST:
    return state.withMutations(map => {
      map.set('loading', true);
      map.set('items', ImmutableList());
    });
  case HISTORY_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('loading', false);
      map.set('items', fromJS(action.history.map((x, i) => ({ ...x, account: x.account.id, original: i === 0 })).reverse()));
    });
  case HISTORY_FETCH_FAIL:
    return state.set('loading', false);
  default:
    return state;
  }
}
