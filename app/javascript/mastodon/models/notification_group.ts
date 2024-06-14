import type {
  ApiAccountRelationshipSeveranceEventJSON,
  ApiAccountWarningJSON,
  BaseNotificationGroupJSON,
  NotificationGroupJSON,
  NotificationJSON,
  NotificationType,
  NotificationWithStatusType,
} from 'mastodon/api_types/notifications';
import type { ApiReportJSON } from 'mastodon/api_types/reports';

// Maximum number of avatars displayed in a notification group
// This corresponds to the max lenght of `group.sampleAccountsIds`
export const NOTIFICATIONS_GROUP_MAX_AVATARS = 6;

interface BaseNotificationGroup
  extends Omit<BaseNotificationGroupJSON, 'sample_accounts'> {
  sampleAccountsIds: string[];
}

interface BaseNotificationWithStatus<Type extends NotificationWithStatusType>
  extends BaseNotificationGroup {
  type: Type;
  statusId: string;
}

interface BaseNotification<Type extends NotificationType>
  extends BaseNotificationGroup {
  type: Type;
}

export type NotificationGroupFavourite =
  BaseNotificationWithStatus<'favourite'>;
export type NotificationGroupReblog = BaseNotificationWithStatus<'reblog'>;
export type NotificationGroupStatus = BaseNotificationWithStatus<'status'>;
export type NotificationGroupMention = BaseNotificationWithStatus<'mention'>;
export type NotificationGroupPoll = BaseNotificationWithStatus<'poll'>;
export type NotificationGroupUpdate = BaseNotificationWithStatus<'update'>;
export type NotificationGroupFollow = BaseNotification<'follow'>;
export type NotificationGroupFollowRequest = BaseNotification<'follow_request'>;
export type NotificationGroupAdminSignUp = BaseNotification<'admin.sign_up'>;

export type AccountWarningAction =
  | 'none'
  | 'disable'
  | 'mark_statuses_as_sensitive'
  | 'delete_statuses'
  | 'sensitive'
  | 'silence'
  | 'suspend';
export interface AccountWarning
  extends Omit<ApiAccountWarningJSON, 'target_account'> {
  targetAccountId: string;
}

export interface NotificationGroupModerationWarning
  extends BaseNotification<'moderation_warning'> {
  moderationWarning: AccountWarning;
}

type AccountRelationshipSeveranceEvent =
  ApiAccountRelationshipSeveranceEventJSON;
export interface NotificationGroupSeveredRelationships
  extends BaseNotification<'severed_relationships'> {
  event: AccountRelationshipSeveranceEvent;
}

interface Report extends Omit<ApiReportJSON, 'target_account'> {
  targetAccountId: string;
}

export interface NotificationGroupAdminReport
  extends BaseNotification<'admin.report'> {
  report: Report;
}

export type NotificationGroup =
  | NotificationGroupFavourite
  | NotificationGroupReblog
  | NotificationGroupStatus
  | NotificationGroupMention
  | NotificationGroupPoll
  | NotificationGroupUpdate
  | NotificationGroupFollow
  | NotificationGroupFollowRequest
  | NotificationGroupModerationWarning
  | NotificationGroupSeveredRelationships
  | NotificationGroupAdminSignUp
  | NotificationGroupAdminReport;

function createReportFromJSON(reportJSON: ApiReportJSON): Report {
  const { target_account, ...report } = reportJSON;
  return {
    targetAccountId: target_account.id,
    ...report,
  };
}

function createAccountWarningFromJSON(
  warningJSON: ApiAccountWarningJSON,
): AccountWarning {
  const { target_account, ...warning } = warningJSON;
  return {
    targetAccountId: target_account.id,
    ...warning,
  };
}

function createAccountRelationshipSeveranceEventFromJSON(
  eventJson: ApiAccountRelationshipSeveranceEventJSON,
): AccountRelationshipSeveranceEvent {
  return eventJson;
}

export function createNotificationGroupFromJSON(
  groupJson: NotificationGroupJSON,
): NotificationGroup {
  const { sample_accounts, ...group } = groupJson;
  const sampleAccountsIds = sample_accounts.map((account) => account.id);

  switch (group.type) {
    case 'favourite':
    case 'reblog':
    case 'status':
    case 'mention':
    case 'poll':
    case 'update': {
      const { status, ...groupWithoutStatus } = group;
      return {
        statusId: status.id,
        sampleAccountsIds,
        ...groupWithoutStatus,
      };
    }
    case 'admin.report': {
      const { report, ...groupWithoutTargetAccount } = group;
      return {
        report: createReportFromJSON(report),
        sampleAccountsIds,
        ...groupWithoutTargetAccount,
      };
    }
    case 'severed_relationships':
      return {
        ...group,
        event: createAccountRelationshipSeveranceEventFromJSON(group.event),
        sampleAccountsIds,
      };

    case 'moderation_warning': {
      const { moderation_warning, ...groupWithoutModerationWarning } = group;
      return {
        ...groupWithoutModerationWarning,
        moderationWarning: createAccountWarningFromJSON(moderation_warning),
        sampleAccountsIds,
      };
    }
    default:
      return {
        sampleAccountsIds,
        ...group,
      };
  }
}

export function createNotificationGroupFromNotificationJSON(
  notification: NotificationJSON,
) {
  const group = {
    sampleAccountsIds: [notification.account.id],
    group_key: notification.group_key,
    notifications_count: 1,
    type: notification.type,
    most_recent_notification_id: notification.id,
    page_min_id: notification.id,
    page_max_id: notification.id,
    latest_page_notification_at: notification.created_at,
  } as NotificationGroup;

  switch (notification.type) {
    case 'favourite':
    case 'reblog':
    case 'status':
    case 'mention':
    case 'poll':
    case 'update':
      return { ...group, statusId: notification.status.id };
    case 'admin.report':
      return { ...group, report: createReportFromJSON(notification.report) };
    case 'severed_relationships':
      return {
        ...group,
        event: createAccountRelationshipSeveranceEventFromJSON(
          notification.event,
        ),
      };
    case 'moderation_warning':
      return {
        ...group,
        moderationWarning: createAccountWarningFromJSON(
          notification.moderation_warning,
        ),
      };
    default:
      return group;
  }
}
