import { apiRequestGet } from 'mastodon/api';
import type { ApiAsyncRefreshJSON } from 'mastodon/api_types/async_refreshes';

export const apiGetAsyncRefresh = (id: string) =>
  apiRequestGet<ApiAsyncRefreshJSON>(`v1_alpha/async_refreshes/${id}`);
