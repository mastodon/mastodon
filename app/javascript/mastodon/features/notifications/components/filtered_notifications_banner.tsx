import { useCallback, useEffect } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { Link, useHistory } from 'react-router-dom';

import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { fetchNotificationPolicy } from 'mastodon/actions/notification_policies';
import { changeSetting } from 'mastodon/actions/settings';
import { Icon } from 'mastodon/components/icon';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';
import { selectSettingsNotificationsMinimizeFilteredBanner } from 'mastodon/selectors/settings';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  filteredNotifications: {
    id: 'notification_requests.title',
    defaultMessage: 'Filtered notifications',
  },
  minimizeToColumnHeader: {
    id: 'notification_requests.minimize_to_column_header',
    defaultMessage: 'Minimize to column header',
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

  if (policy === null || policy.summary.pending_notifications_count === 0) {
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
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const policy = useAppSelector((state) => state.notificationPolicy);
  const minimizeSetting = useAppSelector(
    selectSettingsNotificationsMinimizeFilteredBanner,
  );

  const handleMinimizeToHeader = useCallback(() => {
    dispatch(changeSetting(['notifications', 'minimizeFilteredBanner'], true));
  }, [dispatch]);

  useEffect(() => {
    void dispatch(fetchNotificationPolicy());
    const interval = setInterval(() => {
      void dispatch(fetchNotificationPolicy());
    }, 120000);
    return () => {
      clearInterval(interval);
    };
  }, [dispatch]);

  if (policy === null || policy.summary.pending_notifications_count === 0) {
    return null;
  }

  if (minimizeSetting) {
    return null;
  }

  const menu = [
    {
      text: intl.formatMessage(messages.minimizeToColumnHeader),
      action: handleMinimizeToHeader,
    },
  ];

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

      <DropdownMenuContainer
        items={menu}
        icon='bars'
        iconComponent={MoreHorizIcon}
        size={24}
        direction='right'
        status={null}
        scrollKey={null}
      />
    </Link>
  );
};
