import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';
import { Link, useHistory } from 'react-router-dom';

import { useSelector, useDispatch } from 'react-redux';

import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { initBlockModal } from 'mastodon/actions/blocks';
import { initMuteModal } from 'mastodon/actions/mutes';
import { acceptNotificationRequest, dismissNotificationRequest } from 'mastodon/actions/notifications';
import { initReport } from 'mastodon/actions/reports';
import { Avatar } from 'mastodon/components/avatar';
import { CheckBox } from 'mastodon/components/check_box';
import { IconButton } from 'mastodon/components/icon_button';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';
import { makeGetAccount } from 'mastodon/selectors';
import { toCappedNumber } from 'mastodon/utils/numbers';

const getAccount = makeGetAccount();

const messages = defineMessages({
  accept: { id: 'notification_requests.accept', defaultMessage: 'Accept' },
  dismiss: { id: 'notification_requests.dismiss', defaultMessage: 'Dismiss' },
  view: { id: 'notification_requests.view', defaultMessage: 'View notifications' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  more: { id: 'status.more', defaultMessage: 'More' },
});

export const NotificationRequest = ({ id, accountId, notificationsCount, checked, showCheckbox, toggleCheck }) => {
  const dispatch = useDispatch();
  const account = useSelector(state => getAccount(state, accountId));
  const intl = useIntl();
  const { push: historyPush } = useHistory();

  const handleDismiss = useCallback(() => {
    dispatch(dismissNotificationRequest(id));
  }, [dispatch, id]);

  const handleAccept = useCallback(() => {
    dispatch(acceptNotificationRequest(id));
  }, [dispatch, id]);

  const handleMute = useCallback(() => {
    dispatch(initMuteModal(account));
  }, [dispatch, account]);

  const handleBlock = useCallback(() => {
    dispatch(initBlockModal(account));
  }, [dispatch, account]);

  const handleReport = useCallback(() => {
    dispatch(initReport(account));
  }, [dispatch, account]);

  const handleView = useCallback(() => {
    historyPush(`/notifications/requests/${id}`);
  }, [historyPush, id]);

  const menu = [
    { text: intl.formatMessage(messages.view), action: handleView },
    null,
    { text: intl.formatMessage(messages.accept), action: handleAccept },
    null,
    { text: intl.formatMessage(messages.mute, { name: account.username }), action: handleMute, dangerous: true },
    { text: intl.formatMessage(messages.block, { name: account.username }), action: handleBlock, dangerous: true },
    { text: intl.formatMessage(messages.report, { name: account.username }), action: handleReport, dangerous: true },
  ];

  const handleCheck = useCallback(() => {
    toggleCheck(id);
  }, [toggleCheck, id]);

  const handleClick = useCallback((e) => {
    if (showCheckbox) {
      toggleCheck(id);
      e.preventDefault();
      e.stopPropagation();
    }
  }, [toggleCheck, id, showCheckbox]);

  return (
    /* eslint-disable-next-line jsx-a11y/no-static-element-interactions -- this is just a minor affordance, but we will need a comprehensive accessibility pass */
    <div className={classNames('notification-request', showCheckbox && 'notification-request--forced-checkbox')} onClick={handleClick}>
      <div className='notification-request__checkbox' aria-hidden={!showCheckbox}>
        <CheckBox checked={checked} onChange={handleCheck} />
      </div>
      <Link to={`/notifications/requests/${id}`} className='notification-request__link' onClick={handleClick} title={account?.acct}>
        <Avatar account={account} size={40} counter={toCappedNumber(notificationsCount)} />

        <div className='notification-request__name'>
          <div className='notification-request__name__display-name'>
            <bdi><strong dangerouslySetInnerHTML={{ __html: account?.get('display_name_html') }} /></bdi>
          </div>

          <span>@{account?.get('acct')}</span>
        </div>
      </Link>

      <div className='notification-request__actions'>
        <IconButton iconComponent={DeleteIcon} onClick={handleDismiss} title={intl.formatMessage(messages.dismiss)} />
        <DropdownMenuContainer
          items={menu}
          icons='ellipsis-h'
          iconComponent={MoreHorizIcon}
          direction='right'
          title={intl.formatMessage(messages.more)}
        />
      </div>
    </div>
  );
};

NotificationRequest.propTypes = {
  id: PropTypes.string.isRequired,
  accountId: PropTypes.string.isRequired,
  notificationsCount: PropTypes.string.isRequired,
  checked: PropTypes.bool,
  showCheckbox: PropTypes.bool,
  toggleCheck: PropTypes.func,
};
