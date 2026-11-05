import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { GearIcon } from '@phosphor-icons/react';

import { Button } from '@/mastodon/components/button/redesign';
import { useAppDispatch } from '@/mastodon/store';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { requestBrowserPermission } from 'mastodon/actions/notifications';
import { changeSetting } from 'mastodon/actions/settings';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const NotificationsPermissionBanner: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const handleClick = useCallback(() => {
    dispatch(requestBrowserPermission());
  }, [dispatch]);

  const handleClose = useCallback(() => {
    dispatch(changeSetting(['notifications', 'dismissPermissionBanner'], true));
  }, [dispatch]);

  return (
    <div className='notifications-permission-banner'>
      <div className='notifications-permission-banner__close'>
        <IconButton
          icon='times'
          iconComponent={CloseIcon}
          onClick={handleClose}
          title={intl.formatMessage(messages.close)}
        />
      </div>

      <h2>
        <FormattedMessage
          id='notifications_permission_banner.title'
          defaultMessage='Never miss a thing'
        />
      </h2>
      <p>
        <FormattedMessage
          id='notifications_permission_banner.how_to_control'
          defaultMessage="To receive notifications when Mastodon isn't open, enable desktop notifications. You can control precisely which types of interactions generate desktop notifications through the {icon} button above once they're enabled."
          values={{
            icon: (
              <Icon
                id='sliders'
                icon={GearIcon}
                aria-label={intl.formatMessage({
                  id: 'notifications.settings',
                  defaultMessage: 'Notification Settings',
                })}
              />
            ),
          }}
        />
      </p>
      <Button onClick={handleClick} variant='solid' color='accent' size='sm'>
        <FormattedMessage
          id='notifications_permission_banner.enable'
          defaultMessage='Enable desktop notifications'
        />
      </Button>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default NotificationsPermissionBanner;
