import type { NotificationGroupFollowRequest } from 'mastodon/models/notification_group';
import PersonAddIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import { FormattedMessage } from 'react-intl';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const labelRenderer = values =>
  <FormattedMessage id='notification.follow_request' defaultMessage='{name} has requested to follow you' values={values} />;

export const NotificationFollowRequest: React.FC<{
  notification: NotificationGroupFollowRequest;
}> = ({ notification }) => (
  <NotificationGroupWithStatus
    type='follow-request'
    icon={PersonAddIcon}
    accountIds={notification.sampleAccountsIds}
    timestamp={notification.latest_page_notification_at}
    count={notification.notifications_count}
    labelRenderer={labelRenderer}
  />
);
