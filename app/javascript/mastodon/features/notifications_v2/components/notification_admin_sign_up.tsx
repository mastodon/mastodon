import { useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import PersonAddIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import type { NotificationGroupAdminSignUp } from 'mastodon/models/notification_group';

import { NotificationGroupWithStatus } from './notification_group_with_status';
import { DisplayedName } from './displayed_name';

export const NotificationAdminSignUp: React.FC<{
  notification: NotificationGroupAdminSignUp;
  unread: boolean;
}> = ({ notification, unread }) => {
  const displayedName = (
    <DisplayedName
      accountIds={notification.sampleAccountIds}
    />
  );

  const count = notification.notifications_count;

  const label = useMemo(
    () => {
      if (count === 1)
        return (
          <FormattedMessage
            id='notification.admin.sign_up'
            defaultMessage='{name} signed up'
            values={{ name: displayedName }}
          />
        );
    
      return (
        <FormattedMessage
          id='notification.admin.sign_up'
          defaultMessage='{name} and {count, plural, one {# other} other {# others}} signed up'
          values={{
            name: displayedName,
            count: count - 1,
          }}
        />
      );
    },
    [displayedName, count],
  );

  return (
    <NotificationGroupWithStatus
      type='admin-sign-up'
      icon={PersonAddIcon}
      iconId='person-add'
      accountIds={notification.sampleAccountIds}
      timestamp={notification.latest_page_notification_at}
      label={label}
      unread={unread}
    />
  )
};
