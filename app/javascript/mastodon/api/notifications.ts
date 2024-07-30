import api, { apiRequest, getLinks } from 'mastodon/api';
import type { ApiGenericJSON } from 'mastodon/api_types/generic';

export const apiFetchNotifications = async (params?: {
  exclude_types?: string[];
  max_id?: string;
}) => {
  const response = await api().request<ApiGenericJSON>({
    method: 'GET',
    url: '/api/v2_alpha/notifications',
    params,
  });

  return { apiResult: response.data, links: getLinks(response) };
};

export const apiClearNotifications = () =>
  apiRequest<undefined>('POST', 'v1/notifications/clear');
