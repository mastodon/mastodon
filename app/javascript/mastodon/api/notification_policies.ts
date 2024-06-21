import { apiRequest } from 'mastodon/api';
import type { NotificationPolicyJSON } from 'mastodon/api_types/notification_policies';

export const apiGetNotificationPolicy = () =>
  apiRequest<NotificationPolicyJSON>('GET', '/v1/notifications/policy');

export const apiUpdateNotificationsPolicy = (
  policy: Partial<NotificationPolicyJSON>,
) =>
  apiRequest<NotificationPolicyJSON>('PUT', '/v1/notifications/policy', policy);
