import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import type { NotificationGroupFavourite } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const labelRenderer: LabelRenderer = (displayedName, total, seeMoreHref) => {
  if (total === 1)
    return (
      <FormattedMessage
        id='notification.favourite'
        defaultMessage='{name} favorited your status'
        values={{ name: displayedName }}
      />
    );

  return (
    <FormattedMessage
      id='notification.favourite.name_and_others_with_link'
      defaultMessage='{name} and <a>{count, plural, one {# other} other {# others}}</a> favorited your post'
      values={{
        name: displayedName,
        count: total - 1,
        a: (chunks) =>
          seeMoreHref ? <Link to={seeMoreHref}>{chunks}</Link> : chunks,
      }}
    />
  );
};

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
