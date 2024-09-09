// See app/serializers/rest/notification_group_serializer.rb

import type { AccountWarningAction } from 'mastodon/models/notification_group';

import type { ApiAccountJSON } from './accounts';
import type { ApiReportJSON } from './reports';
import type { ApiStatusJSON } from './statuses';

// See app/model/notification.rb
export const allNotificationTypes = [
  'follow',
  'follow_request',
  'favourite',
  'reblog',
  'mention',
  'poll',
  'status',
  'update',
  'admin.sign_up',
  'admin.report',
  'moderation_warning',
  'severed_relationships',
];

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

export interface BaseNotificationJSON {
  id: string;
  type: NotificationType;
  created_at: string;
  group_key: string;
  account: ApiAccountJSON;
}

export interface BaseNotificationGroupJSON {
  group_key: string;
  notifications_count: number;
  type: NotificationType;
  sample_account_ids: string[];
  latest_page_notification_at: string; // FIXME: This will only be present if the notification group is returned in a paginated list, not requested directly
  most_recent_notification_id: string;
  page_min_id?: string;
  page_max_id?: string;
}

interface NotificationGroupWithStatusJSON extends BaseNotificationGroupJSON {
  type: NotificationWithStatusType;
  status_id: string | null;
}

interface NotificationWithStatusJSON extends BaseNotificationJSON {
  type: NotificationWithStatusType;
  status: ApiStatusJSON | null;
}

interface ReportNotificationGroupJSON extends BaseNotificationGroupJSON {
  type: 'admin.report';
  report: ApiReportJSON;
}

interface ReportNotificationJSON extends BaseNotificationJSON {
  type: 'admin.report';
  report: ApiReportJSON;
}

type SimpleNotificationTypes = 'follow' | 'follow_request' | 'admin.sign_up';
interface SimpleNotificationGroupJSON extends BaseNotificationGroupJSON {
  type: SimpleNotificationTypes;
}

interface SimpleNotificationJSON extends BaseNotificationJSON {
  type: SimpleNotificationTypes;
}

export interface ApiAccountWarningJSON {
  id: string;
  action: AccountWarningAction;
  text: string;
  status_ids: string[];
  created_at: string;
  target_account: ApiAccountJSON;
  appeal: unknown;
}

interface ModerationWarningNotificationGroupJSON
  extends BaseNotificationGroupJSON {
  type: 'moderation_warning';
  moderation_warning: ApiAccountWarningJSON;
}

interface ModerationWarningNotificationJSON extends BaseNotificationJSON {
  type: 'moderation_warning';
  moderation_warning: ApiAccountWarningJSON;
}

export interface ApiAccountRelationshipSeveranceEventJSON {
  id: string;
  type: 'account_suspension' | 'domain_block' | 'user_domain_block';
  purged: boolean;
  target_name: string;
  followers_count: number;
  following_count: number;
  created_at: string;
}

interface AccountRelationshipSeveranceNotificationGroupJSON
  extends BaseNotificationGroupJSON {
  type: 'severed_relationships';
  event: ApiAccountRelationshipSeveranceEventJSON;
}

interface AccountRelationshipSeveranceNotificationJSON
  extends BaseNotificationJSON {
  type: 'severed_relationships';
  event: ApiAccountRelationshipSeveranceEventJSON;
}

export type ApiNotificationJSON =
  | SimpleNotificationJSON
  | ReportNotificationJSON
  | AccountRelationshipSeveranceNotificationJSON
  | NotificationWithStatusJSON
  | ModerationWarningNotificationJSON;

export type ApiNotificationGroupJSON =
  | SimpleNotificationGroupJSON
  | ReportNotificationGroupJSON
  | AccountRelationshipSeveranceNotificationGroupJSON
  | NotificationGroupWithStatusJSON
  | ModerationWarningNotificationGroupJSON;

export interface ApiNotificationGroupsResultJSON {
  accounts: ApiAccountJSON[];
  statuses: ApiStatusJSON[];
  notification_groups: ApiNotificationGroupJSON[];
}
