import { FormattedMessage } from 'react-intl';

import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import type { NotificationGroupQuotedUpdate } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer: LabelRenderer = (displayedName) => (
  <FormattedMessage
    id='notification.quoted_update'
    defaultMessage='{name} edited a post you have quoted'
    values={{ name: displayedName }}
  />
);

export const NotificationQuotedUpdate: React.FC<{
  notification: NotificationGroupQuotedUpdate;
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
