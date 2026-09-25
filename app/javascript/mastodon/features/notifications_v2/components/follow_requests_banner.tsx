import { FormattedMessage } from 'react-intl';

import { UserPlusIcon } from '@phosphor-icons/react';

import { useFollowRequestsCount } from '../../navigation_panel/redesign';
import { LinkBanner } from '../../notifications/components/filtered_notifications_banner';

/**
 * This banner is only shown to users whose notification policy filters
 * or blocks notifications from accounts that are not following them,
 * so that they have a way of finding out about pending requests.
 */
export const FollowRequestsBanner: React.FC = () => {
  const followRequestsCount = useFollowRequestsCount({ fetch: false });

  if (followRequestsCount === 0) {
    return null;
  }

  return (
    <LinkBanner
      to='/follow_requests'
      icon={<UserPlusIcon size={24} />}
      title={
        <FormattedMessage
          id='column.follow_requests'
          defaultMessage='Follow requests'
        />
      }
      subtitle={
        <FormattedMessage
          id='follow_requests.pending_requests'
          defaultMessage='From {count, plural, =0 {no one} one {one person} other {# people}} you may know'
          values={{ count: followRequestsCount }}
        />
      }
    />
  );
};
