import { defineMessages, FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { isRedesignEnabled } from '@/mastodon/utils/environment';
import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import type { NotificationGroupFavourite } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const messagesLegacy = defineMessages({
  like: {
    id: 'notification.favourite',
    defaultMessage: '{name} favorited your post',
  },
  likeByMultiple: {
    id: 'notification.favourite.name_and_others_with_link',
    defaultMessage:
      '{name} and <a>{count, plural, one {# other} other {# others}}</a> favorited your post',
  },
  messageLike: {
    id: 'notification.favourite_pm',
    defaultMessage: '{name} favorited your private mention',
  },
  messageLikeByMultiple: {
    id: 'notification.favourite_pm.name_and_others_with_link',
    defaultMessage:
      '{name} and <a>{count, plural, one {# other} other {# others}}</a> favorited your private mention',
  },
});

const messagesRedesign = defineMessages({
  like: {
    id: 'notification.like',
    defaultMessage: '{name} liked your post',
  },
  likeByMultiple: {
    id: 'notification.like.name_and_others_with_link',
    defaultMessage:
      '{name} and <a>{count, plural, one {# other} other {# others}}</a> liked your post',
  },
  messageLike: {
    id: 'notification.like_message',
    defaultMessage: '{name} liked your message',
  },
  messageLikeByMultiple: {
    id: 'notification.like_message.name_and_others_with_link',
    defaultMessage:
      '{name} and <a>{count, plural, one {# other} other {# others}}</a> liked your message',
  },
});

const messages = isRedesignEnabled() ? messagesRedesign : messagesLegacy;

const labelRenderer: LabelRenderer = (displayedName, total, seeMoreHref) => {
  if (total === 1)
    return (
      <FormattedMessage {...messages.like} values={{ name: displayedName }} />
    );

  return (
    <FormattedMessage
      {...messages.likeByMultiple}
      values={{
        name: displayedName,
        count: total - 1,
        a: (chunks) =>
          seeMoreHref ? <Link to={seeMoreHref}>{chunks}</Link> : chunks,
      }}
    />
  );
};

const privateLabelRenderer: LabelRenderer = (
  displayedName,
  total,
  seeMoreHref,
) => {
  if (total === 1)
    return (
      <FormattedMessage
        {...messages.messageLike}
        values={{ name: displayedName }}
      />
    );

  return (
    <FormattedMessage
      {...messages.messageLikeByMultiple}
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

  const isPrivateMention = useAppSelector(
    (state) => state.statuses.getIn([statusId, 'visibility']) === 'direct',
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
      labelRenderer={isPrivateMention ? privateLabelRenderer : labelRenderer}
      labelSeeMoreHref={
        statusAccount ? `/@${statusAccount}/${statusId}/favourites` : undefined
      }
      unread={unread}
    />
  );
};
