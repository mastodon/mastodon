import type { NotificationGroupUpdate } from 'mastodon/models/notification_group';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import { FormattedMessage } from 'react-intl';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer = values =>
  <FormattedMessage id='notification.update' defaultMessage='{name} edited a post' values={values} />;

export const NotificationUpdate: React.FC<{
  notification: NotificationGroupUpdate;
}> = ({ notification }) => (
  <NotificationWithStatus
    type='update'
    icon={EditIcon}
    accountIds={notification.sampleAccountsIds}
    count={notification.notifications_count}
    statusId={notification.statusId}
    labelRenderer={labelRenderer}
  />
);
