import type { NotificationGroupStatus } from 'mastodon/models/notification_group';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications_active-fill.svg?react';
import { FormattedMessage } from 'react-intl';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer = values =>
  <FormattedMessage id='notification.status' defaultMessage='{name} just posted' values={values} />;

export const NotificationStatus: React.FC<{
  notification: NotificationGroupStatus;
}> = ({ notification }) => (
  <NotificationWithStatus
    type='status'
    icon={NotificationsActiveIcon}
    accountIds={notification.sampleAccountsIds}
    count={notification.notifications_count}
    statusId={notification.statusId}
    labelRenderer={labelRenderer}
  />
);
