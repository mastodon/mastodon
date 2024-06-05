import type { NotificationGroupSeveredRelationships } from 'mastodon/models/notification_group';
import { RelationshipsSeveranceEvent } from 'mastodon/features/notifications/components/relationships_severance_event';

export const NotificationSeveredRelationships: React.FC<{
  notification: NotificationGroupSeveredRelationships;
}> = ({ notification: { event } }) => (
  <RelationshipsSeveranceEvent
    type={event.type}
    target={event.target_name}
    followersCount={event.followers_count}
    followingCount={event.following_count}
  />
);
