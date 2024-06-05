import type { NotificationGroupFollow } from 'mastodon/models/notification_group';
import PersonAddIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import { FormattedMessage } from 'react-intl';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const labelRenderer = values =>
  <FormattedMessage id='notification.follow' defaultMessage='{name} followed you' values={values} />;

export const NotificationFollow: React.FC<{
  notification: NotificationGroupFollow;
}> = ({ notification }) => (
  <NotificationGroupWithStatus
    type='follow'
    icon={PersonAddIcon}
    accountIds={notification.sampleAccountsIds}
    timestamp={notification.latest_page_notification_at}
    count={notification.notifications_count}
    labelRenderer={labelRenderer}
  />
);
