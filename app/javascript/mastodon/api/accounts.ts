import { apiRequest } from 'mastodon/api';
import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';

export const apiSubmitAccountNote = (id: string, value: string) =>
  apiRequest<ApiRelationshipJSON>('post', `v1/accounts/${id}/note`, {
    comment: value,
  });
