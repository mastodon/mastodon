import { POLL_VOTE_SUCCESS, POLL_FETCH_SUCCESS } from 'mastodon/actions/polls';
import { POLLS_IMPORT } from 'mastodon/actions/importer';
import { Map as ImmutableMap, fromJS } from 'immutable';

const importPolls = (state, polls) => state.withMutations(map => polls.forEach(poll => map.set(poll.id, fromJS(poll))));

const initialState = ImmutableMap();

export default function polls(state = initialState, action) {
  switch(action.type) {
  case POLLS_IMPORT:
    return importPolls(state, action.polls);
  case POLL_VOTE_SUCCESS:
  case POLL_FETCH_SUCCESS:
    return importPolls(state, [action.poll]);
  default:
    return state;
  }
}
