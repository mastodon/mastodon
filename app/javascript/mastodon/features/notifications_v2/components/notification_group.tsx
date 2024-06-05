import type { NotificationGroup as NotificationGroupModel } from 'mastodon/models/notification_group';
import { useMemo } from 'react';
import { useAppSelector } from 'mastodon/store';

import { HotKeys } from 'react-hotkeys';

import { NotificationReblog } from './notification_reblog';
import { NotificationFavourite } from './notification_favourite';
import { NotificationSeveredRelationships } from './notification_severed_relationships';
import { NotificationMention } from './notification_mention';
import { NotificationFollow } from './notification_follow';
import { NotificationFollowRequest } from './notification_follow_request';
import { NotificationPoll } from './notification_poll';
import { NotificationStatus } from './notification_status';
import { NotificationUpdate } from './notification_update';
import { NotificationAdminSignUp } from './notification_admin_sign_up';
import { NotificationAdminReport } from './notification_admin_report';
import { NotificationModerationWarning } from './notification_moderation_warning';

export const NotificationGroup: React.FC<{
  notificationGroupId: NotificationGroupModel['group_key'];
  unread: boolean;
  onMoveUp: unknown;
  onMoveDown: unknown;
}> = ({ notificationGroupId, onMoveUp, onMoveDown }) => {
  const notificationGroup = useAppSelector((state) =>
    state.notificationsGroups.groups.find(
      (item) => item.type !== 'gap' && item.group_key === notificationGroupId,
    ),
  );

  if (!notificationGroup || notificationGroup.type === 'gap') return null;

  let content;

  switch (notificationGroup.type) {
    case 'reblog':
      content = <NotificationReblog notification={notificationGroup} />;
      break;
    case 'favourite':
      content = <NotificationFavourite notification={notificationGroup} />;
      break;
    case 'severed_relationships':
      content = <NotificationSeveredRelationships notification={notificationGroup} />;
      break;
    case 'mention':
      content = <NotificationMention notification={notificationGroup} />;;
      break;
    case 'follow':
      content = <NotificationFollow notification={notificationGroup} />;
      break;
    case 'follow_request':
      content = <NotificationFollowRequest notification={notificationGroup} />;
      break;
    case 'poll':
      content = <NotificationPoll notification={notificationGroup} />;
      break;
    case 'status':
      content = <NotificationStatus notification={notificationGroup} />;
      break;
    case 'update':
      content = <NotificationUpdate notification={notificationGroup} />;
      break;
    case 'admin.sign_up':
      content = <NotificationAdminSignUp notification={notificationGroup} />;
      break;
    case 'admin.report':
      content = <NotificationAdminReport notification={notificationGroup} />;
      break;
    case 'moderation_warning':
      content = <NotificationModerationWarning notification={notificationGroup} />;
      break;
    default:
      return null;
  }

  const handlers = useMemo(() => ({
    moveUp: () => {
      onMoveUp(notificationGroupId)
    },

    moveDown: () => {
      onMoveDown(notificationGroupId)
    },

    reply: () => {},

    favourite: () => {},

    boost: () => {},

    mention: () => {},

    open: () => {},

    openProfile: () => {},

    toggleHidden: () => {},
  }), [notificationGroupId, onMoveUp, onMoveDown]);

  return (
    <HotKeys handlers={handlers}>
      {content}
    </HotKeys>
  );
};
