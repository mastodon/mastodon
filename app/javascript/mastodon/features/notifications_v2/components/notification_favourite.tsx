import { useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import type { NotificationGroupFavourite } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import { NotificationGroupWithStatus } from './notification_group_with_status';
import { DisplayedName } from './displayed_name';

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

  const displayedName = (
    <DisplayedName
      accountIds={notification.sampleAccountIds}
    />
  );

  const count = notification.notifications_count;

  const seeMoreHref =
    statusAccount ? `/@${statusAccount}/${statusId}/favourites` : undefined

  const label = useMemo(
    () => {
      if (count === 1)
      return (
        <FormattedMessage
          id='notification.favourite'
          defaultMessage='{name} favorited your post'
          values={{ name: displayedName }}
        />
      );

      if (seeMoreHref)
        return (
          <FormattedMessage
            id='notification.favourite.name_and_others_with_link'
            defaultMessage='{name} and <a>{count, plural, one {# other} other {# others}}</a> favorited your post'
            values={{
              name: displayedName,
              count: count - 1,
              a: (chunks) => <Link to={seeMoreHref}>{chunks}</Link>,
            }}
          />
        );
    
      return (
        <FormattedMessage
          id='notification.favourite.name_and_others'
          defaultMessage='{name} and {count, plural, one {# other} other {# others}} favorited your post'
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
      type='favourite'
      icon={StarIcon}
      iconId='star'
      accountIds={notification.sampleAccountIds}
      statusId={notification.statusId}
      timestamp={notification.latest_page_notification_at}
      label={label}
      unread={unread}
    />
  );
};
