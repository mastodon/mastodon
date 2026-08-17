import type { ApiNotificationRequestJSON } from 'mastodon/api_types/notifications';

export interface NotificationRequest extends Omit<
  ApiNotificationRequestJSON,
  'account' | 'notifications_count'
> {
  account_id: string;
  notifications_count: number;
}

export function createNotificationRequestFromJSON(
  requestJSON: ApiNotificationRequestJSON,
): NotificationRequest {
  const { account, notifications_count, ...request } = requestJSON;

  return {
    account_id: account.id,
    notifications_count: +notifications_count,
    ...request,
  };
}
