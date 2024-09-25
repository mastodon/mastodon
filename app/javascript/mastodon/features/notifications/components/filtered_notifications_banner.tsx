import { useCallback, useEffect } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { Link, useHistory } from 'react-router-dom';

import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import { fetchNotificationPolicy } from 'mastodon/actions/notification_policies';
import { Icon } from 'mastodon/components/icon';
import { selectSettingsNotificationsMinimizeFilteredBanner } from 'mastodon/selectors/settings';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  filteredNotifications: {
    id: 'notification_requests.title',
    defaultMessage: 'Filtered notifications',
  },
});

export const FilteredNotificationsIconButton: React.FC<{
  className?: string;
}> = ({ className }) => {
  const intl = useIntl();
  const history = useHistory();
  const policy = useAppSelector((state) => state.notificationPolicy);
  const minimizeSetting = useAppSelector(
    selectSettingsNotificationsMinimizeFilteredBanner,
  );

  const handleClick = useCallback(() => {
    history.push('/notifications/requests');
  }, [history]);

  if (policy === null || policy.summary.pending_requests_count <= 0) {
    return null;
  }

  if (!minimizeSetting) {
    return null;
  }

  return (
    <button
      aria-label={intl.formatMessage(messages.filteredNotifications)}
      title={intl.formatMessage(messages.filteredNotifications)}
      onClick={handleClick}
      className={className}
    >
      <Icon id='filtered-notifications' icon={InventoryIcon} />
    </button>
  );
};

export const FilteredNotificationsBanner: React.FC = () => {
  const dispatch = useAppDispatch();
  const policy = useAppSelector((state) => state.notificationPolicy);
  const minimizeSetting = useAppSelector(
    selectSettingsNotificationsMinimizeFilteredBanner,
  );

  useEffect(() => {
    void dispatch(fetchNotificationPolicy());

    const interval = setInterval(() => {
      void dispatch(fetchNotificationPolicy());
    }, 120000);

    return () => {
      clearInterval(interval);
    };
  }, [dispatch]);

  if (policy === null || policy.summary.pending_requests_count <= 0) {
    return null;
  }

  if (minimizeSetting) {
    return null;
  }

  return (
    <Link
      className='filtered-notifications-banner'
      to='/notifications/requests'
    >
      <div className='notification-group__icon'>
        <Icon icon={InventoryIcon} id='filtered-notifications' />
      </div>

      <div className='filtered-notifications-banner__text'>
        <strong>
          <FormattedMessage
            id='filtered_notifications_banner.title'
            defaultMessage='Filtered notifications'
          />
        </strong>
        <span>
          <FormattedMessage
            id='filtered_notifications_banner.pending_requests'
            defaultMessage='From {count, plural, =0 {no one} one {one person} other {# people}} you may know'
            values={{ count: policy.summary.pending_requests_count }}
          />
        </span>
      </div>
    </Link>
  );
};
