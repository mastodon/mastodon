import { apiGetPoll, apiPollVote } from 'mastodon/api/polls';
import type { ApiPollJSON } from 'mastodon/api_types/polls';
import { createPollFromServerJSON } from 'mastodon/models/poll';
import {
  createAppAsyncThunk,
  createDataLoadingThunk,
} from 'mastodon/store/typed_functions';

import { importPolls } from './importer/polls';

export const importFetchedPoll = createAppAsyncThunk(
  'poll/importFetched',
  (args: { poll: ApiPollJSON }, { dispatch, getState }) => {
    const { poll } = args;

    dispatch(
      importPolls({
        polls: [createPollFromServerJSON(poll, getState().polls[poll.id])],
      }),
    );
  },
);

export const vote = createDataLoadingThunk(
  'poll/vote',
  ({ pollId, choices }: { pollId: string; choices: string[] }) =>
    apiPollVote(pollId, choices),
  async (poll, { dispatch, discardLoadData }) => {
    await dispatch(importFetchedPoll({ poll }));
    return discardLoadData;
  },
);

export const fetchPoll = createDataLoadingThunk(
  'poll/fetch',
  ({ pollId }: { pollId: string }) => apiGetPoll(pollId),
  async (poll, { dispatch }) => {
    await dispatch(importFetchedPoll({ poll }));
  },
);
