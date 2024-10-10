import type { ApiPollJSON } from 'mastodon/api_types/polls';
import { createPollFromServerJSON } from 'mastodon/models/poll';
import {
  createAppAsyncThunk,
  createDataLoadingThunk,
} from 'mastodon/store/typed_functions';

import { apiRequest } from '../api';

import { importPolls } from './importer/polls';

export const importFetchedPoll = createAppAsyncThunk(
  'poll/importFetched',
  (args: { poll: ApiPollJSON }, { dispatch, getState }) => {
    const { poll } = args;

    dispatch(
      importPolls({
        polls: [createPollFromServerJSON(poll, getState().polls.get(poll.id))],
      }),
    );
  },
);

export const vote = createDataLoadingThunk(
  'poll/vote',
  ({ pollId, choices }: { pollId: string; choices: unknown }) =>
    apiRequest<ApiPollJSON>('POST', `/v1/polls/${pollId}/votes`, {
      choices,
    }),
  async (poll, { dispatch, discardLoadData }) => {
    await dispatch(importFetchedPoll({ poll }));
    return discardLoadData;
  },
);

export const fetchPoll = createDataLoadingThunk(
  'poll/fetch',
  ({ pollId }: { pollId: string }) =>
    apiRequest<ApiPollJSON>('GET', `/v1/polls/${pollId}`),
  async (poll, { dispatch }) => {
    await dispatch(importFetchedPoll({ poll }));
  },
);
