import type {
  BaseNotificationGroupJSON,
  NotificationGroupJSON,
  NotificationType,
  NotificationWithStatusType,
} from 'mastodon/api_types/notifications';

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

// TODO: those two will need special types
export type NotificationGroupModerationWarning =
  BaseNotification<'moderation_warning'>;
export type NotificationGroupAdminReport = BaseNotification<'admin.report'>;
export type NotificationGroupSeveredRelationships =
  BaseNotification<'severed_relationships'>;

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

export function createNotificationGroupFromJSON(
  groupJson: NotificationGroupJSON,
): NotificationGroup {
  const { sample_accounts, ...group } = groupJson;
  const sampleAccountsIds = sample_accounts.map((account) => account.id);

  if ('status' in group) {
    const { status, ...groupWithoutStatus } = group;
    return {
      statusId: status.id,
      sampleAccountsIds,
      ...groupWithoutStatus,
    };
  }

  return {
    sampleAccountsIds,
    ...group,
  };
}
