import type {
  ApiAccountRelationshipSeveranceEventJSON,
  ApiAccountWarningJSON,
  ApiAnnualReportEventJSON,
  BaseNotificationGroupJSON,
  ApiNotificationGroupJSON,
  ApiNotificationJSON,
  NotificationType,
  NotificationWithStatusType,
} from 'mastodon/api_types/notifications';
import type { ApiReportJSON } from 'mastodon/api_types/reports';

// Maximum number of avatars displayed in a notification group
// This corresponds to the max length of `group.sampleAccountIds`
export const NOTIFICATIONS_GROUP_MAX_AVATARS = 8;

interface BaseNotificationGroup extends Omit<
  BaseNotificationGroupJSON,
  'sample_account_ids'
> {
  sampleAccountIds: string[];
  partial: boolean;
}

interface BaseNotificationWithStatus<
  Type extends NotificationWithStatusType,
> extends BaseNotificationGroup {
  type: Type;
  statusId: string | undefined;
}

interface BaseNotification<
  Type extends NotificationType,
> extends BaseNotificationGroup {
  type: Type;
}

export type NotificationGroupFavourite =
  BaseNotificationWithStatus<'favourite'>;
export type NotificationGroupReblog = BaseNotificationWithStatus<'reblog'>;
export type NotificationGroupStatus = BaseNotificationWithStatus<'status'>;
export type NotificationGroupMention = BaseNotificationWithStatus<'mention'>;
export type NotificationGroupQuote = BaseNotificationWithStatus<'quote'>;
export type NotificationGroupPoll = BaseNotificationWithStatus<'poll'>;
export type NotificationGroupUpdate = BaseNotificationWithStatus<'update'>;
export type NotificationGroupQuotedUpdate =
  BaseNotificationWithStatus<'quoted_update'>;
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
export interface AccountWarning extends Omit<
  ApiAccountWarningJSON,
  'target_account'
> {
  targetAccountId: string;
}

export interface NotificationGroupModerationWarning extends BaseNotification<'moderation_warning'> {
  moderationWarning: AccountWarning;
}

type AccountRelationshipSeveranceEvent =
  ApiAccountRelationshipSeveranceEventJSON;
export interface NotificationGroupSeveredRelationships extends BaseNotification<'severed_relationships'> {
  event: AccountRelationshipSeveranceEvent;
}

type AnnualReportEvent = ApiAnnualReportEventJSON;
export interface NotificationGroupAnnualReport extends BaseNotification<'annual_report'> {
  annualReport: AnnualReportEvent;
}

interface Report extends Omit<ApiReportJSON, 'target_account'> {
  targetAccountId: string;
}

export interface NotificationGroupAdminReport extends BaseNotification<'admin.report'> {
  report: Report;
}

export type NotificationGroup =
  | NotificationGroupFavourite
  | NotificationGroupReblog
  | NotificationGroupStatus
  | NotificationGroupMention
  | NotificationGroupQuote
  | NotificationGroupPoll
  | NotificationGroupUpdate
  | NotificationGroupQuotedUpdate
  | NotificationGroupFollow
  | NotificationGroupFollowRequest
  | NotificationGroupModerationWarning
  | NotificationGroupSeveredRelationships
  | NotificationGroupAdminSignUp
  | NotificationGroupAdminReport
  | NotificationGroupAnnualReport;

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

function createAnnualReportEventFromJSON(
  eventJson: ApiAnnualReportEventJSON,
): AnnualReportEvent {
  return eventJson;
}

export function createNotificationGroupFromJSON(
  groupJson: ApiNotificationGroupJSON,
): NotificationGroup {
  const { sample_account_ids: sampleAccountIds, ...group } = groupJson;

  switch (group.type) {
    case 'favourite':
    case 'reblog':
    case 'status':
    case 'mention':
    case 'quote':
    case 'poll':
    case 'update':
    case 'quoted_update': {
      const { status_id: statusId, ...groupWithoutStatus } = group;
      return {
        statusId: statusId ?? undefined,
        sampleAccountIds,
        partial: false,
        ...groupWithoutStatus,
      };
    }
    case 'admin.report': {
      const { report, ...groupWithoutTargetAccount } = group;
      return {
        report: createReportFromJSON(report),
        sampleAccountIds,
        partial: false,
        ...groupWithoutTargetAccount,
      };
    }
    case 'severed_relationships':
      return {
        ...group,
        partial: false,
        event: createAccountRelationshipSeveranceEventFromJSON(group.event),
        sampleAccountIds,
      };
    case 'moderation_warning': {
      const { moderation_warning, ...groupWithoutModerationWarning } = group;
      return {
        ...groupWithoutModerationWarning,
        partial: false,
        moderationWarning: createAccountWarningFromJSON(moderation_warning),
        sampleAccountIds,
      };
    }
    case 'annual_report': {
      const { annual_report, ...groupWithoutAnnualReport } = group;
      return {
        ...groupWithoutAnnualReport,
        partial: false,
        annualReport: createAnnualReportEventFromJSON(annual_report),
        sampleAccountIds,
      };
    }
    default:
      return {
        sampleAccountIds,
        partial: false,
        ...group,
      };
  }
}

export function createNotificationGroupFromNotificationJSON(
  notification: ApiNotificationJSON,
): NotificationGroup {
  const group = {
    sampleAccountIds: [notification.account.id],
    group_key: notification.group_key,
    notifications_count: 1,
    most_recent_notification_id: notification.id,
    page_min_id: notification.id,
    page_max_id: notification.id,
    latest_page_notification_at: notification.created_at,
    partial: true,
  };

  switch (notification.type) {
    case 'favourite':
    case 'reblog':
    case 'status':
    case 'mention':
    case 'quote':
    case 'poll':
    case 'update':
    case 'quoted_update':
      return {
        ...group,
        type: notification.type,
        statusId: notification.status?.id,
      };
    case 'admin.report':
      return {
        ...group,
        type: notification.type,
        report: createReportFromJSON(notification.report),
      };
    case 'severed_relationships':
      return {
        ...group,
        type: notification.type,
        event: createAccountRelationshipSeveranceEventFromJSON(
          notification.event,
        ),
      };
    case 'moderation_warning':
      return {
        ...group,
        type: notification.type,
        moderationWarning: createAccountWarningFromJSON(
          notification.moderation_warning,
        ),
      };
    default:
      return {
        ...group,
        type: notification.type,
      };
  }
}
