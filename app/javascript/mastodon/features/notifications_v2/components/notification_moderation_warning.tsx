import { ModerationWarning } from 'mastodon/features/notifications/components/moderation_warning';
import type { NotificationGroupModerationWarning } from 'mastodon/models/notification_group';

export const NotificationModerationWarning: React.FC<{
  notification: NotificationGroupModerationWarning;
  unread: boolean;
}> = ({ notification: { event }, unread }) => (
  <ModerationWarning action={event.action} id={event.id} unread={unread} />
);
