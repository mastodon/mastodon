import PropTypes from 'prop-types';
import { useRef, useCallback, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { useSelector, useDispatch } from 'react-redux';

import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import { fetchNotificationRequests, expandNotificationRequests } from 'mastodon/actions/notifications';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import ScrollableList from 'mastodon/components/scrollable_list';

import { NotificationRequest } from './components/notification_request';

const messages = defineMessages({
  title: { id: 'notification_requests.title', defaultMessage: 'Filtered notifications' },
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

  return (
    <Column bindToDocument={!multiColumn} ref={columnRef} label={intl.formatMessage(messages.title)}>
      <ColumnHeader
        icon='archive'
        iconComponent={InventoryIcon}
        title={intl.formatMessage(messages.title)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
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
