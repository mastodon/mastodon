import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { UserPlusIcon } from '@phosphor-icons/react';

import { Icon } from 'mastodon/components/icon';
import { useAppSelector } from 'mastodon/store';

import { useFollowRequestsCount } from '../../navigation_panel/redesign';

/**
 * This banner is only shown to users whose notification policy filters
 * or blocks notifications from accounts that are not following them,
 * so that they have a way of finding out about pending requests.
 */
export const FollowRequestsBanner: React.FC = () => {
  const followRequestsCount = useFollowRequestsCount({ fetch: false });
  const isUserRejectingNonFollowerNotifications = useAppSelector(
    ({ notificationPolicy }) =>
      notificationPolicy
        ? notificationPolicy.for_not_followers !== 'accept'
        : null,
  );

  if (followRequestsCount === 0 || !isUserRejectingNonFollowerNotifications) {
    return null;
  }

  return (
    <Link className='filtered-notifications-banner' to='/follow_requests'>
      <div className='notification-group__icon'>
        <Icon icon={UserPlusIcon} id='filtered-notifications' />
      </div>

      <div className='filtered-notifications-banner__text'>
        <strong>
          <FormattedMessage
            id='column.follow_requests'
            defaultMessage='Follow requests'
          />
        </strong>
        <span>
          <FormattedMessage
            id='follow_requests.pending_requests'
            defaultMessage='From {count, plural, =0 {no one} one {one person} other {# people}} you may know'
            values={{ count: followRequestsCount }}
          />
        </span>
      </div>
    </Link>
  );
};
