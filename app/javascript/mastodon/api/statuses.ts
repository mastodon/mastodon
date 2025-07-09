import { apiRequestGet } from 'mastodon/api';
import type { ApiContextJSON } from 'mastodon/api_types/statuses';

export const apiGetContext = (statusId: string) =>
  apiRequestGet<ApiContextJSON>(`v1/statuses/${statusId}/context`);
