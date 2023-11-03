import type { ApiRelationshipJSON } from 'flavours/glitch/api_types/relationships';
import { createAppAsyncThunk } from 'flavours/glitch/store/typed_functions';

import api from '../api';

export const submitAccountNote = createAppAsyncThunk(
  'account_note/submit',
  async (args: { id: string; value: string }, { getState }) => {
    const response = await api(getState).post<ApiRelationshipJSON>(
      `/api/v1/accounts/${args.id}/note`,
      {
        comment: args.value,
      },
    );

    return { relationship: response.data };
  },
);
