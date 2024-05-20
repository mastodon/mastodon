import type {
  BaseNotificationGroupJSON,
  NotificationGroupJSON,
  NotificationType,
  NotificationWithStatusType,
} from 'mastodon/api_types/notifications';
import type { ApiStatusJSON } from 'mastodon/api_types/statuses';

type BaseNotificationGroup = BaseNotificationGroupJSON;

interface BaseNotificationWithStatus<Type extends NotificationWithStatusType>
  extends BaseNotificationGroup {
  type: Type;
  status: ApiStatusJSON;
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
  // @ts-expect-error -- FIXME: properly convert the special notifications here
  return groupJson;
}
