import api, { getLinks } from 'mastodon/api';
import type { ApiNotificationGroupJSON } from 'mastodon/api_types/notifications';

export const apiFetchNotifications = async (
  params?: {
    exclude_types?: string[];
  },
  forceUrl?: string,
) => {
  const response = await api().request<ApiNotificationGroupJSON[]>({
    method: 'GET',
    url: forceUrl ?? '/api/v2_alpha/notifications',
    params,
  });

  return { notifications: response.data, links: getLinks(response) };
};
