// See app/serializers/rest/notification_policy_serializer.rb

export type NotificationPolicyValue = 'accept' | 'filter' | 'drop';

export interface NotificationPolicyJSON {
  for_not_following: NotificationPolicyValue;
  for_not_followers: NotificationPolicyValue;
  for_new_accounts: NotificationPolicyValue;
  for_private_mentions: NotificationPolicyValue;
  for_limited_accounts: NotificationPolicyValue;
  summary: {
    pending_requests_count: number;
    pending_notifications_count: number;
  };
}
