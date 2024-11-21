import type { JSX } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import PersonAddIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import { FollowersCounter } from 'mastodon/components/counters';
import { FollowButton } from 'mastodon/components/follow_button';
import { ShortNumber } from 'mastodon/components/short_number';
import { me } from 'mastodon/initial_state';
import type { NotificationGroupFollow } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const labelRenderer: LabelRenderer = (displayedName, total, seeMoreHref) => {
  if (total === 1)
    return (
      <FormattedMessage
        id='notification.follow'
        defaultMessage='{name} followed you'
        values={{ name: displayedName }}
      />
    );

  return (
    <FormattedMessage
      id='notification.follow.name_and_others'
      defaultMessage='{name} and <a>{count, plural, one {# other} other {# others}}</a> followed you'
      values={{
        name: displayedName,
        count: total - 1,
        a: (chunks) =>
          seeMoreHref ? <Link to={seeMoreHref}>{chunks}</Link> : chunks,
      }}
    />
  );
};

const FollowerCount: React.FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAppSelector((s) => s.accounts.get(accountId));

  if (!account) return null;

  return (
    <ShortNumber value={account.followers_count} renderer={FollowersCounter} />
  );
};

export const NotificationFollow: React.FC<{
  notification: NotificationGroupFollow;
  unread: boolean;
}> = ({ notification, unread }) => {
  const username = useAppSelector(
    (state) => state.accounts.getIn([me, 'username']) as string,
  );

  let actions: JSX.Element | undefined;
  let additionalContent: JSX.Element | undefined;

  if (notification.sampleAccountIds.length === 1) {
    // only display those if the group contains 1 account, otherwise it does not makes sense
    const account = notification.sampleAccountIds[0];

    if (account) {
      actions = <FollowButton accountId={notification.sampleAccountIds[0]} />;
      additionalContent = <FollowerCount accountId={account} />;
    }
  }

  return (
    <NotificationGroupWithStatus
      type='follow'
      icon={PersonAddIcon}
      iconId='person-add'
      accountIds={notification.sampleAccountIds}
      timestamp={notification.latest_page_notification_at}
      count={notification.notifications_count}
      labelRenderer={labelRenderer}
      labelSeeMoreHref={`/@${username}/followers`}
      unread={unread}
      actions={actions}
      additionalContent={additionalContent}
    />
  );
};
