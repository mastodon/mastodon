import type { ApiPollJSON } from 'mastodon/api_types/polls';
import { createPollFromServerJSON } from 'mastodon/models/poll';
import { createAppAsyncThunk } from 'mastodon/store';

import api from '../api';

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

export const vote = createAppAsyncThunk(
  'poll/vote',
  async (
    args: {
      pollId: string;
      choices: unknown;
    },
    { dispatch, getState },
  ) => {
    const { pollId, choices } = args;

    const { data } = await api(getState).post<ApiPollJSON>(
      `/api/v1/polls/${pollId}/votes`,
      {
        choices,
      },
    );

    void dispatch(importFetchedPoll({ poll: data }));
  },
);

export const fetchPoll = createAppAsyncThunk(
  'poll/fetch',
  async (args: { pollId: string }, { dispatch, getState }) => {
    const { data } = await api(getState).get<ApiPollJSON>(
      `/api/v1/polls/${args.pollId}`,
    );

    void dispatch(importFetchedPoll({ poll: data }));
  },
);
