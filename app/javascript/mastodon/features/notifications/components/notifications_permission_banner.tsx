import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { useAppDispatch } from '@/mastodon/store';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import UnfoldMoreIcon from '@/material-icons/400-24px/unfold_more.svg?react';
import { requestBrowserPermission } from 'mastodon/actions/notifications';
import { changeSetting } from 'mastodon/actions/settings';
import { Button } from 'mastodon/components/button';
import { messages as columnHeaderMessages } from 'mastodon/components/column_header';
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
                icon={UnfoldMoreIcon}
                aria-label={intl.formatMessage(columnHeaderMessages.show)}
              />
            ),
          }}
        />
      </p>
      <Button onClick={handleClick}>
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
