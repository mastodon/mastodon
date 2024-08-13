import { useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import type { NotificationGroupReblog } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import { NotificationGroupWithStatus } from './notification_group_with_status';
import { DisplayedName } from './displayed_name';

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

  const displayedName = (
    <DisplayedName
      accountIds={notification.sampleAccountIds}
    />
  );

  const count = notification.notifications_count;

  const seeMoreHref =
    statusAccount ? `/@${statusAccount}/${statusId}/reblogs` : undefined

  const label = useMemo(
    () => {
      if (count === 1)
      return (
        <FormattedMessage
          id='notification.reblog'
          defaultMessage='{name} boosted your status'
          values={{ name: displayedName }}
        />
      );

      if (seeMoreHref)
        return (
          <FormattedMessage
            id='notification.reblog.name_and_others_with_link'
            defaultMessage='{name} and <a>{count, plural, one {# other} other {# others}}</a> boosted your post'
            values={{
              name: displayedName,
              count: count - 1,
              a: (chunks) => <Link to={seeMoreHref}>{chunks}</Link>,
            }}
          />
        );

      return (
        <FormattedMessage
          id='notification.reblog.name_and_others'
          defaultMessage='{name} and {count, plural, one {# other} other {# others}} boosted your post'
          values={{
            name: displayedName,
            count: count - 1,
          }}
        />
      );
    },
    [displayedName, count, seeMoreHref],
  );

  return (
    <NotificationGroupWithStatus
      type='reblog'
      icon={RepeatIcon}
      iconId='repeat'
      accountIds={notification.sampleAccountIds}
      statusId={notification.statusId}
      timestamp={notification.latest_page_notification_at}
      label={label}
      unread={unread}
    />
  );
};
