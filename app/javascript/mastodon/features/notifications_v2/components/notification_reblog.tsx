import type { NotificationGroupReblog } from 'mastodon/models/notification_group';

export const NotificationReblog: React.FC<{
  notification: NotificationGroupReblog;
}> = ({ notification }) => {
  return <div>reblog {notification.group_key}</div>;
};
