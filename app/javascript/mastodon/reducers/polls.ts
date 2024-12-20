import type { Reducer } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';

import { importPolls } from 'mastodon/actions/importer/polls';
import { makeEmojiMap } from 'mastodon/models/custom_emoji';
import { createPollOptionTranslationFromServerJSON } from 'mastodon/models/poll';
import type { Poll } from 'mastodon/models/poll';

import {
  STATUS_TRANSLATE_SUCCESS,
  STATUS_TRANSLATE_UNDO,
} from '../actions/statuses';

const initialState = ImmutableMap<string, Poll>();
type PollsState = typeof initialState;

const statusTranslateSuccess = (
  state: PollsState,
  pollTranslation: Poll | undefined,
) => {
  if (!pollTranslation) return state;

  return state.withMutations((map) => {
    const poll = state.get(pollTranslation.id);

    if (!poll) return;

    const emojiMap = makeEmojiMap(poll.emojis);

    pollTranslation.options.forEach((item, index) => {
      map.setIn(
        [pollTranslation.id, 'options', index, 'translation'],
        createPollOptionTranslationFromServerJSON(item, emojiMap),
      );
    });
  });
};

const statusTranslateUndo = (state: PollsState, id: string) => {
  return state.withMutations((map) => {
    const options = map.get(id)?.options;

    if (options) {
      options.forEach((item, index) =>
        map.deleteIn([id, 'options', index, 'translation']),
      );
    }
  });
};

export const pollsReducer: Reducer<PollsState> = (
  state = initialState,
  action,
) => {
  if (importPolls.match(action)) {
    return state.withMutations((polls) => {
      action.payload.polls.forEach((poll) => polls.set(poll.id, poll));
    });
  } else if (action.type === STATUS_TRANSLATE_SUCCESS)
    return statusTranslateSuccess(
      state,
      (action.translation as { poll?: Poll }).poll,
    );
  else if (action.type === STATUS_TRANSLATE_UNDO)
    return statusTranslateUndo(state, action.pollId as string);
  else return state;
};
