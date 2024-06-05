import type { NotificationGroupModerationWarning } from 'mastodon/models/notification_group';
import { ModerationWarning } from 'mastodon/features/notifications/components/moderation_warning';

export const NotificationModerationWarning: React.FC<{
  notification: NotificationGroupModerationWarning;
}> = ({ notification: { event } }) => (
  <ModerationWarning
    action={event.action}
    id={event.id}
  />
);
