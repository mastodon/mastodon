// See app/serializers/rest/notification_group_serializer.rb

import type { ApiAccountJSON } from './accounts';
import type { ApiStatusJSON } from './statuses';

// See app/model/notification.rb
export type NotificationWithStatusType =
  | 'favourite'
  | 'reblog'
  | 'status'
  | 'mention'
  | 'poll'
  | 'update';

export type NotificationType =
  | NotificationWithStatusType
  | 'follow'
  | 'follow_request'
  | 'moderation_warning'
  | 'severed_relationships'
  | 'admin.sign_up'
  | 'admin.report';

export interface BaseNotificationGroupJSON {
  group_key: string;
  notifications_count: number;
  type: NotificationType;
  sample_accounts: ApiAccountJSON[];
  latest_page_notification_at?: string;
  page_min_id?: string;
  page_max_id?: string;
}

interface NotificationGroupWithStatusJSON extends BaseNotificationGroupJSON {
  type: NotificationWithStatusType;
  status: ApiStatusJSON;
}

interface ReportNotificationGroupJSON extends BaseNotificationGroupJSON {
  type: 'admin.report';
  report: unknown;
}

interface ModerationWarningNotificationGroupJSON
  extends BaseNotificationGroupJSON {
  type: 'moderation_warning';
  moderation_warning: unknown;
}

interface AccountRelationshipSeveranceNotificationGroupJSON
  extends BaseNotificationGroupJSON {
  type: 'severed_relationships';
  account_relationship_severance_event: unknown;
}

export type NotificationGroupJSON =
  | ReportNotificationGroupJSON
  | AccountRelationshipSeveranceNotificationGroupJSON
  | NotificationGroupWithStatusJSON
  | ModerationWarningNotificationGroupJSON;
