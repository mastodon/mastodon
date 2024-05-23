import { apiRequest } from 'flavours/glitch/api';
import type { ApiRelationshipJSON } from 'flavours/glitch/api_types/relationships';

export const apiSubmitAccountNote = (id: string, value: string) =>
  apiRequest<ApiRelationshipJSON>('post', `v1/accounts/${id}/note`, {
    comment: value,
  });
