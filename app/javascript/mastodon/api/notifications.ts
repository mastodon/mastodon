import { apiRequest } from 'mastodon/api';
import type { NotificationGroupJSON } from 'mastodon/api_types/notifications';

export const apiFetchNotifications = () => {
  return apiRequest<NotificationGroupJSON[]>('GET', '/v2_alpha/notifications');
};
