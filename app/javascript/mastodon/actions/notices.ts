import { createAppAsyncThunk } from 'mastodon/store/typed_functions';

import api from '../api';

export interface ApiNoticeActionJSON {
  label: string;
  url: string;
}

export interface ApiNoticeJSON {
  id: string;
  title: string;
  message: string;
  icon?: string;
  actions: ApiNoticeActionJSON[];
}

export const fetchNotices = createAppAsyncThunk(
  'notices/fetch',
  async (_, { getState }) => {
    const response = await api(getState).get<ApiNoticeJSON[]>(
      '/api/v1/notices',
    );

    return { notices: response.data };
  },
);

export const dismissNotice = createAppAsyncThunk(
  'notices/dismiss',
  async (args: { id: string }, { getState }) => {
    await api(getState).delete<unknown>(`/api/v1/notices/${args.id}`);

    return {};
  },
);
