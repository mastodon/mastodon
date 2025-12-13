import api, { apiRequestPost, getLinks } from 'mastodon/api';
import type { ApiStatusJSON } from 'mastodon/api_types/statuses';
import type { StatusVisibility } from 'mastodon/models/status';

export const apiReblog = (statusId: string, visibility: StatusVisibility) =>
  apiRequestPost<{ reblog: ApiStatusJSON }>(`v1/statuses/${statusId}/reblog`, {
    visibility,
  });

export const apiUnreblog = (statusId: string) =>
  apiRequestPost<ApiStatusJSON>(`v1/statuses/${statusId}/unreblog`);

export const apiRevokeQuote = (quotedStatusId: string, statusId: string) =>
  apiRequestPost<ApiStatusJSON>(
    `v1/statuses/${quotedStatusId}/quotes/${statusId}/revoke`,
  );

export const apiGetQuotes = async (statusId: string, url?: string) => {
  const response = await api().request<ApiStatusJSON[]>({
    method: 'GET',
    url: url ?? `/api/v1/statuses/${statusId}/quotes`,
  });

  return {
    statuses: response.data,
    links: getLinks(response),
  };
};
