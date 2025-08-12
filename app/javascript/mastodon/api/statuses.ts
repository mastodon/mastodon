import api, {
  apiRequestGet,
  apiRequestPut,
  getAsyncRefreshHeader,
} from 'mastodon/api';
import type {
  ApiContextJSON,
  ApiStatusJSON,
  ApiStatusSourceJSON,
} from 'mastodon/api_types/statuses';

import type { ApiQuotePolicy } from '../api_types/quotes';

export const apiGetContext = async (statusId: string) => {
  const response = await api().request<ApiContextJSON>({
    method: 'GET',
    url: `/api/v1/statuses/${statusId}/context`,
  });

  return {
    context: response.data,
    refresh: getAsyncRefreshHeader(response),
  };
};

export const apiSetQuotePolicy = async (
  statusId: string,
  policy: ApiQuotePolicy,
) => {
  const { text } = await apiRequestGet<ApiStatusSourceJSON>(
    `v1/statuses/${statusId}/source`,
  );
  return apiRequestPut<ApiStatusJSON>(`v1/statuses/${statusId}`, {
    quote_approval_policy: policy,
    status: text,
  });
};
