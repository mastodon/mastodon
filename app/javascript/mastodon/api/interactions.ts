import { apiRequest } from 'mastodon/api';
import type { Status, StatusVisibility } from 'mastodon/models/status';

export const apiReblog = (statusId: string, visibility: StatusVisibility) =>
  apiRequest<{ reblog: Status }>('post', `v1/statuses/${statusId}/reblog`, {
    visibility,
  });

export const apiUnreblog = (statusId: string) =>
  apiRequest<Status>('post', `v1/statuses/${statusId}/unreblog`);
