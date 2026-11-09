import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { TrayIcon } from '@phosphor-icons/react';

import { LockupLink, LockupWrapper } from '@/mastodon/components/lockup';
import type { MastodonLocationDescriptor } from '@/mastodon/components/router';
import { fetchNotificationPolicy } from 'mastodon/actions/notification_policies';
import { selectSettingsNotificationsMinimizeFilteredBanner } from 'mastodon/selectors/settings';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import classes from './filtered_notifications_banner.module.scss';

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
    <LinkBanner
      to='/notifications/requests'
      icon={<TrayIcon size={24} />}
      title={
        <FormattedMessage
          id='filtered_notifications_banner.title'
          defaultMessage='Filtered notifications'
        />
      }
      subtitle={
        <FormattedMessage
          id='filtered_notifications_banner.pending_requests'
          defaultMessage='From {count, plural, =0 {no one} one {one person} other {# people}} you may know'
          values={{ count: policy.summary.pending_requests_count }}
        />
      }
    />
  );
};

interface LinkBannerProps {
  to: MastodonLocationDescriptor;
  icon: React.ReactNode;
  title: React.ReactNode;
  subtitle: React.ReactNode;
}

export const LinkBanner: React.FC<LinkBannerProps> = ({
  to,
  icon,
  title,
  subtitle,
}) => {
  return (
    <LockupWrapper icon={icon} className={classes.lockup}>
      <LockupLink to={to} subtitle={subtitle} isHotkeyNavigationTarget={false}>
        {title}
      </LockupLink>
    </LockupWrapper>
  );
};
