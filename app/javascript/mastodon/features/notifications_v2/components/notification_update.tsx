import { FormattedMessage } from 'react-intl';

import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import type { NotificationGroupUpdate } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer: LabelRenderer = (displayedName) => (
  <FormattedMessage
    id='notification.update'
    defaultMessage='{name} edited a post'
    values={{ name: displayedName }}
  />
);

export const NotificationUpdate: React.FC<{
  notification: NotificationGroupUpdate;
  unread: boolean;
}> = ({ notification, unread }) => (
  <NotificationWithStatus
    type='update'
    icon={EditIcon}
    iconId='edit'
    accountIds={notification.sampleAccountIds}
    count={notification.notifications_count}
    statusId={notification.statusId}
    labelRenderer={labelRenderer}
    unread={unread}
  />
);
