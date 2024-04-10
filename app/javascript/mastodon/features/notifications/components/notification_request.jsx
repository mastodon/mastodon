import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { useSelector, useDispatch } from 'react-redux';

import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import DoneIcon from '@/material-icons/400-24px/done.svg?react';
import { acceptNotificationRequest, dismissNotificationRequest } from 'mastodon/actions/notifications';
import { Avatar } from 'mastodon/components/avatar';
import { IconButton } from 'mastodon/components/icon_button';
import { makeGetAccount } from 'mastodon/selectors';
import { toCappedNumber } from 'mastodon/utils/numbers';

const getAccount = makeGetAccount();

const messages = defineMessages({
  accept: { id: 'notification_requests.accept', defaultMessage: 'Accept' },
  dismiss: { id: 'notification_requests.dismiss', defaultMessage: 'Dismiss' },
});

export const NotificationRequest = ({ id, accountId, notificationsCount }) => {
  const dispatch = useDispatch();
  const account = useSelector(state => getAccount(state, accountId));
  const intl = useIntl();

  const handleDismiss = useCallback(() => {
    dispatch(dismissNotificationRequest(id));
  }, [dispatch, id]);

  const handleAccept = useCallback(() => {
    dispatch(acceptNotificationRequest(id));
  }, [dispatch, id]);

  return (
    <div className='notification-request'>
      <Link to={`/notifications/requests/${id}`} className='notification-request__link'>
        <Avatar account={account} size={36} />

        <div className='notification-request__name'>
          <div className='notification-request__name__display-name'>
            <bdi><strong dangerouslySetInnerHTML={{ __html: account?.get('display_name_html') }} /></bdi>
            <span className='filtered-notifications-banner__badge'>{toCappedNumber(notificationsCount)}</span>
          </div>

          <span>@{account?.get('acct')}</span>
        </div>
      </Link>

      <div className='notification-request__actions'>
        <IconButton iconComponent={DeleteIcon} onClick={handleDismiss} title={intl.formatMessage(messages.dismiss)} />
        <IconButton iconComponent={DoneIcon} onClick={handleAccept} title={intl.formatMessage(messages.accept)} />
      </div>
    </div>
  );
};

NotificationRequest.propTypes = {
  id: PropTypes.string.isRequired,
  accountId: PropTypes.string.isRequired,
  notificationsCount: PropTypes.string.isRequired,
};
