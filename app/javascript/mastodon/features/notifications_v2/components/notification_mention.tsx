import { FormattedMessage } from 'react-intl';

import ReplyIcon from '@/material-icons/400-24px/reply-fill.svg?react';
import type { NotificationGroupMention } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer: LabelRenderer = (values) => (
  <FormattedMessage
    id='notification.mention'
    defaultMessage='{name} mentioned you'
    values={values}
  />
);

export const NotificationMention: React.FC<{
  notification: NotificationGroupMention;
  unread: boolean;
}> = ({ notification, unread }) => (
  <NotificationWithStatus
    type='mention'
    icon={ReplyIcon}
    iconId='reply'
    accountIds={notification.sampleAccountsIds}
    count={notification.notifications_count}
    statusId={notification.statusId}
    labelRenderer={labelRenderer}
    unread={unread}
  />
);
