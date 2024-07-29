import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { useSelector, useDispatch } from 'react-redux';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import DoneIcon from '@/material-icons/400-24px/done.svg?react';
import { acceptNotificationRequest, dismissNotificationRequest } from 'mastodon/actions/notifications';
import { Avatar } from 'mastodon/components/avatar';
import { Icon } from 'mastodon/components/icon';
import { makeGetAccount } from 'mastodon/selectors';
import { toCappedNumber } from 'mastodon/utils/numbers';

const getAccount = makeGetAccount();

export const NotificationRequest = ({ id, accountId, notificationsCount }) => {
  const dispatch = useDispatch();
  const account = useSelector(state => getAccount(state, accountId));

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

        <Icon id='chevron-right' icon={ChevronRightIcon} className='notification-request__disclosure-indicator' />
      </Link>

      <div className='notification-request__actions'>
        <button type='button' className='button button-tertiary button--destructive' onClick={handleDismiss}>
          <Icon id='times' icon={DeleteIcon} />
          <FormattedMessage id='notification_requests.dismiss' defaultMessage='Dismiss' />
        </button>
        <button type='button' className='button button-tertiary' onClick={handleAccept}>
          <Icon id='check' icon={DoneIcon} />
          <FormattedMessage id='notification_requests.accept' defaultMessage='Accept' />
        </button>
      </div>
    </div>
  );
};

NotificationRequest.propTypes = {
  id: PropTypes.string.isRequired,
  accountId: PropTypes.string.isRequired,
  notificationsCount: PropTypes.string.isRequired,
};
