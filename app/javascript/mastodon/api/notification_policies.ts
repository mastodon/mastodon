import { apiRequestGet, apiRequestPut } from 'mastodon/api';
import type { NotificationPolicyJSON } from 'mastodon/api_types/notification_policies';

export const apiGetNotificationPolicy = () =>
  apiRequestGet<NotificationPolicyJSON>('v2/notifications/policy');

export const apiUpdateNotificationsPolicy = (
  policy: Partial<NotificationPolicyJSON>,
) => apiRequestPut<NotificationPolicyJSON>('v2/notifications/policy', policy);
