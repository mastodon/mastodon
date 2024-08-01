import PropTypes from 'prop-types';
import { useRef, useCallback, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { useSelector, useDispatch } from 'react-redux';

import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { fetchNotificationRequests, expandNotificationRequests, acceptNotificationRequests, dismissNotificationRequests } from 'mastodon/actions/notifications';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import ScrollableList from 'mastodon/components/scrollable_list';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';

import { NotificationRequest } from './components/notification_request';

const messages = defineMessages({
  title: { id: 'notification_requests.title', defaultMessage: 'Filtered notifications' },
  accept_all: { id: 'notification_requests.accept_all', defaultMessage: 'Accept all notification requests' },
  dismiss_all: { id: 'notification_requests.dismiss_all', defaultMessage: 'Dismiss all notification requests' },
  confirm_accept_all_title: { id: 'notification_requests.confirm_accept_all.title', defaultMessage: 'Accept notification requests?' },
  confirm_accept_all_message: { id: 'notification_requests.confirm_accept_all.message', defaultMessage: 'You are about to accept {count, plural, one {one notification request} other {# notification requests}}. Are you sure you want to proceed?' },
  confirm_accept_all_button: { id: 'notification_requests.confirm_accept_all.button', defaultMessage: 'Accept all' },
  confirm_dismiss_all_title: { id: 'notification_requests.confirm_dismiss_all.title', defaultMessage: 'Dismiss notification requests?' },
  confirm_dismiss_all_message: { id: 'notification_requests.confirm_dismiss_all.message', defaultMessage: "You are about to dismiss {count, plural, one {one notification request} other {# notification requests}}. You won't be able to easily access {count, plural, one {it} other {them}} again. Are you sure you want to proceed?" },
  confirm_dismiss_all_button: { id: 'notification_requests.confirm_dismiss_all.button', defaultMessage: 'Dismiss all' },
});

export const NotificationRequests = ({ multiColumn }) => {
  const columnRef = useRef();
  const intl = useIntl();
  const dispatch = useDispatch();
  const isLoading = useSelector(state => state.getIn(['notificationRequests', 'isLoading']));
  const notificationRequests = useSelector(state => state.getIn(['notificationRequests', 'items']));
  const hasMore = useSelector(state => !!state.getIn(['notificationRequests', 'next']));

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, [columnRef]);

  const handleLoadMore = useCallback(() => {
    dispatch(expandNotificationRequests());
  }, [dispatch]);

  useEffect(() => {
    dispatch(fetchNotificationRequests());
  }, [dispatch]);

  const handleAcceptAll = useCallback(() => {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.confirm_accept_all_title),
        message: intl.formatMessage(messages.confirm_accept_all_message, { count: notificationRequests.size }),
        confirm: intl.formatMessage(messages.confirm_accept_all_button),
        onConfirm: () =>
          dispatch(acceptNotificationRequests(notificationRequests.map((request) => request.get('id')))),
      },
    }));
  }, [dispatch, notificationRequests, intl]);

  const handleDismissAll = useCallback(() => {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.confirm_dismiss_all_title),
        message: intl.formatMessage(messages.confirm_dismiss_all_message, { count: notificationRequests.size }),
        confirm: intl.formatMessage(messages.confirm_dismiss_all_button),
        onConfirm: () =>
          dispatch(dismissNotificationRequests(notificationRequests.map((request) => request.get('id')))),
      }
    }));
  }, [dispatch, notificationRequests, intl]);

  const menu = [
    { text: intl.formatMessage(messages.accept_all), action: handleAcceptAll },
    { text: intl.formatMessage(messages.dismiss_all), action: handleDismissAll, dangerous: true },
  ];

  const dropDownMenu = (
    <DropdownMenuContainer
      className='column-header__button'
      items={menu}
      icon='ellipsis-v'
      iconComponent={MoreHorizIcon}
      size={24}
      direction='right'
    />
  );

  return (
    <Column bindToDocument={!multiColumn} ref={columnRef} label={intl.formatMessage(messages.title)}>
      <ColumnHeader
        icon='archive'
        iconComponent={InventoryIcon}
        title={intl.formatMessage(messages.title)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
        extraButton={dropDownMenu}
        showBackButton
      />

      <ScrollableList
        scrollKey='notification_requests'
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
        isLoading={isLoading}
        showLoading={isLoading && notificationRequests.size === 0}
        hasMore={hasMore}
        onLoadMore={handleLoadMore}
        emptyMessage={<FormattedMessage id='empty_column.notification_requests' defaultMessage='All clear! There is nothing here. When you receive new notifications, they will appear here according to your settings.' />}
      >
        {notificationRequests.map(request => (
          <NotificationRequest
            key={request.get('id')}
            id={request.get('id')}
            accountId={request.get('account')}
            notificationsCount={request.get('notifications_count')}
          />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

NotificationRequests.propTypes = {
  multiColumn: PropTypes.bool,
};

export default NotificationRequests;
