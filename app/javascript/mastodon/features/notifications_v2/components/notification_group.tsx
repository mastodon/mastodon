import type { NotificationGroup as NotificationGroupModel } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import { NotificationReblog } from './notification_reblog';

export const NotificationGroup: React.FC<{
  notificationGroupId: NotificationGroupModel['group_key'];
  unread: boolean;
  onMoveUp: unknown;
  onMoveDown: unknown;
}> = ({ notificationGroupId }) => {
  const notificationGroup = useAppSelector((state) =>
    state.notificationsGroups.groups.find(
      (item) => item.type !== 'gap' && item.group_key === notificationGroupId,
    ),
  );

  if (!notificationGroup || notificationGroup.type === 'gap') return null;

  switch (notificationGroup.type) {
    case 'reblog':
      return <NotificationReblog notification={notificationGroup} />;
    case 'follow':
    case 'follow_request':
    case 'favourite':
    case 'mention':
    case 'poll':
    case 'status':
    case 'update':
    case 'admin.sign_up':
    case 'admin.report':
    case 'moderation_warning':
    case 'severed_relationships':
    default:
      return (
        <div>
          <pre>{JSON.stringify(notificationGroup, undefined, 2)}</pre>
          <hr />
        </div>
      );
  }
};
