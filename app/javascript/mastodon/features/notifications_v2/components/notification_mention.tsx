import type { NotificationGroupMention } from 'mastodon/models/notification_group';
import ReplyIcon from '@/material-icons/400-24px/reply-fill.svg?react';
import { FormattedMessage } from 'react-intl';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer = values =>
  <FormattedMessage id='notification.mention' defaultMessage='{name} mentioned you' values={values} />;

export const NotificationMention: React.FC<{
  notification: NotificationGroupMention;
}> = ({ notification }) => (
  <NotificationWithStatus
    type='mention'
    icon={ReplyIcon}
    accountIds={notification.sampleAccountsIds}
    count={notification.notifications_count}
    statusId={notification.statusId}
    labelRenderer={labelRenderer}
  />
);
