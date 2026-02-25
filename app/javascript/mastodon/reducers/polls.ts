import type { Reducer } from '@reduxjs/toolkit';

import { importPolls } from 'mastodon/actions/importer/polls';
import { createPollOptionTranslationFromServerJSON } from 'mastodon/models/poll';
import type { Poll } from 'mastodon/models/poll';

import {
  STATUS_TRANSLATE_SUCCESS,
  STATUS_TRANSLATE_UNDO,
} from '../actions/statuses';

const initialState: Record<string, Poll> = {};
type PollsState = typeof initialState;

const statusTranslateSuccess = (state: PollsState, pollTranslation?: Poll) => {
  if (!pollTranslation) return;

  const poll = state[pollTranslation.id];

  if (!poll) return;

  pollTranslation.options.forEach((item, index) => {
    const option = poll.options[index];
    if (!option) return;

    option.translation = createPollOptionTranslationFromServerJSON(item);
  });
};

const statusTranslateUndo = (state: PollsState, id: string) => {
  state[id]?.options.forEach((option) => {
    option.translation = null;
  });
};

export const pollsReducer: Reducer<PollsState> = (
  draft = initialState,
  action,
) => {
  if (importPolls.match(action)) {
    action.payload.polls.forEach((poll) => {
      draft[poll.id] = poll;
    });
  } else if (action.type === STATUS_TRANSLATE_SUCCESS)
    statusTranslateSuccess(draft, (action.translation as { poll?: Poll }).poll);
  else if (action.type === STATUS_TRANSLATE_UNDO) {
    statusTranslateUndo(draft, action.pollId as string);
  }

  return draft;
};
