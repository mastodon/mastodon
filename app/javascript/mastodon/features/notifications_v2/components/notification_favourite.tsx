import { FormattedMessage } from 'react-intl';

import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import type { NotificationGroupFavourite } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

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
  unread: boolean;
}> = ({ notification, unread }) => {
  const { statusId } = notification;
  const statusAccount = useAppSelector(
    (state) =>
      state.accounts.get(state.statuses.getIn([statusId, 'account']) as string)
        ?.acct,
  );

  return (
    <NotificationGroupWithStatus
      type='favourite'
      icon={StarIcon}
      iconId='star'
      accountIds={notification.sampleAccountIds}
      statusId={notification.statusId}
      timestamp={notification.latest_page_notification_at}
      count={notification.notifications_count}
      labelRenderer={labelRenderer}
      labelSeeMoreHref={
        statusAccount ? `/@${statusAccount}/${statusId}/favourites` : undefined
      }
      unread={unread}
    />
  );
};
