import { FormattedMessage } from 'react-intl';

import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import type { NotificationGroupFavourite } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const labelRenderer: LabelRenderer = (values) => (
  <FormattedMessage
    id='notification.favourite'
    defaultMessage='{name} favorited your status'
    values={values}
  />
);

export const NotificationFavourite: React.FC<{
  notification: NotificationGroupFavourite;
}> = ({ notification }) => (
  <NotificationGroupWithStatus
    type='favourite'
    icon={StarIcon}
    accountIds={notification.sampleAccountsIds}
    statusId={notification.statusId}
    timestamp={notification.latest_page_notification_at}
    count={notification.notifications_count}
    labelRenderer={labelRenderer}
  />
);
