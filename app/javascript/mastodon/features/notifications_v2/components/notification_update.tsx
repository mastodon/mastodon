import { FormattedMessage } from 'react-intl';

import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import type { NotificationGroupUpdate } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_with_status';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer: LabelRenderer = (values) => (
  <FormattedMessage
    id='notification.update'
    defaultMessage='{name} edited a post'
    values={values}
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
    statusId={notification.statusId}
    labelRenderer={labelRenderer}
    unread={unread}
  />
);
