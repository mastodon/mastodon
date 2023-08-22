import { createAsyncThunk } from '@reduxjs/toolkit';
import type { AxiosResponse } from 'axios';

import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';
import type { GetState } from 'mastodon/store';

import api from '../api';

export const submitAccountNote = createAsyncThunk(
  'account_note/submit',
  async (args: { id: string; value: string }, { getState }) => {
    const response: AxiosResponse<ApiRelationshipJSON> = await api(
      getState as GetState,
    ).post<ApiRelationshipJSON>(`/api/v1/accounts/${args.id}/note`, {
      comment: args.value,
    });

    return { relationship: response.data };
  },
);
