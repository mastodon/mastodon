import { FormattedMessage } from 'react-intl';

import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import type { NotificationGroupReblog } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const labelRenderer: LabelRenderer = (values) => (
  <FormattedMessage
    id='notification.reblog'
    defaultMessage='{name} boosted your status'
    values={values}
  />
);

export const NotificationReblog: React.FC<{
  notification: NotificationGroupReblog;
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
      type='reblog'
      icon={RepeatIcon}
      iconId='repeat'
      accountIds={notification.sampleAccountIds}
      statusId={notification.statusId}
      timestamp={notification.latest_page_notification_at}
      count={notification.notifications_count}
      labelRenderer={labelRenderer}
      labelSeeMoreHref={
        statusAccount ? `/@${statusAccount}/${statusId}/reblogs` : undefined
      }
      unread={unread}
    />
  );
};
