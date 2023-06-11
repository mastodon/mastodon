import { Map as ImmutableMap, fromJS } from 'immutable';

import { POLLS_IMPORT } from 'flavours/glitch/actions/importer';

import { normalizePollOptionTranslation } from '../actions/importer/normalizer';
import { STATUS_TRANSLATE_SUCCESS, STATUS_TRANSLATE_UNDO } from '../actions/statuses';

const importPolls = (state, polls) => state.withMutations(map => polls.forEach(poll => map.set(poll.id, fromJS(poll))));

const statusTranslateSuccess = (state, pollTranslation) => {
  return state.withMutations(map => {
    if (pollTranslation) {
      const poll = state.get(pollTranslation.id);

      pollTranslation.options.forEach((item, index) => {
        map.setIn([pollTranslation.id, 'options', index, 'translation'], fromJS(normalizePollOptionTranslation(item, poll)));
      });
    }
  });
};

const statusTranslateUndo = (state, id) => {
  return state.withMutations(map => {
    const options = map.getIn([id, 'options']);

    if (options) {
      options.forEach((item, index) => map.deleteIn([id, 'options', index, 'translation']));
    }
  });
};

const initialState = ImmutableMap();

export default function polls(state = initialState, action) {
  switch(action.type) {
  case POLLS_IMPORT:
    return importPolls(state, action.polls);
  case STATUS_TRANSLATE_SUCCESS:
    return statusTranslateSuccess(state, action.translation.poll);
  case STATUS_TRANSLATE_UNDO:
    return statusTranslateUndo(state, action.pollId);
  default:
    return state;
  }
}
