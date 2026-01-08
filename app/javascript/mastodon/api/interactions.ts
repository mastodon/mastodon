import { apiRequestPost } from 'mastodon/api';
import type { ApiStatusJSON } from 'mastodon/api_types/statuses';
import type { StatusVisibility } from 'mastodon/models/status';

export const apiReblog = (statusId: string, visibility: StatusVisibility) =>
  apiRequestPost<{ reblog: ApiStatusJSON }>(`v1/statuses/${statusId}/reblog`, {
    visibility,
  });

export const apiUnreblog = (statusId: string) =>
  apiRequestPost<ApiStatusJSON>(`v1/statuses/${statusId}/unreblog`);
