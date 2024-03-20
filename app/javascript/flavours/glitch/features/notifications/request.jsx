import PropTypes from 'prop-types';
import { useRef, useCallback, useEffect } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { useSelector, useDispatch } from 'react-redux';

import DoneIcon from '@/material-icons/400-24px/done.svg?react';
import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import VolumeOffIcon from '@/material-icons/400-24px/volume_off.svg?react';
import { fetchNotificationRequest, fetchNotificationsForRequest, expandNotificationsForRequest, acceptNotificationRequest, dismissNotificationRequest } from 'flavours/glitch/actions/notifications';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import { IconButton } from 'flavours/glitch/components/icon_button';
import ScrollableList from 'flavours/glitch/components/scrollable_list';
import { SensitiveMediaContextProvider } from 'flavours/glitch/features/ui/util/sensitive_media_context';

import NotificationContainer from './containers/notification_container';

const messages = defineMessages({
  title: { id: 'notification_requests.notifications_from', defaultMessage: 'Notifications from {name}' },
  accept: { id: 'notification_requests.accept', defaultMessage: 'Accept' },
  dismiss: { id: 'notification_requests.dismiss', defaultMessage: 'Dismiss' },
});

const selectChild = (ref, index, alignTop) => {
  const container = ref.current.node;
  const element = container.querySelector(`article:nth-of-type(${index + 1}) .focusable`);

  if (element) {
    if (alignTop && container.scrollTop > element.offsetTop) {
      element.scrollIntoView(true);
    } else if (!alignTop && container.scrollTop + container.clientHeight < element.offsetTop + element.offsetHeight) {
      element.scrollIntoView(false);
    }

    element.focus();
  }
};

export const NotificationRequest = ({ multiColumn, params: { id } }) => {
  const columnRef = useRef();
  const intl = useIntl();
  const dispatch = useDispatch();
  const notificationRequest = useSelector(state => state.getIn(['notificationRequests', 'current', 'item', 'id']) === id ? state.getIn(['notificationRequests', 'current', 'item']) : null);
  const accountId = notificationRequest?.get('account');
  const account = useSelector(state => state.getIn(['accounts', accountId]));
  const notifications = useSelector(state => state.getIn(['notificationRequests', 'current', 'notifications', 'items']));
  const isLoading = useSelector(state => state.getIn(['notificationRequests', 'current', 'notifications', 'isLoading']));
  const hasMore = useSelector(state => !!state.getIn(['notificationRequests', 'current', 'notifications', 'next']));
  const removed = useSelector(state => state.getIn(['notificationRequests', 'current', 'removed']));

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, [columnRef]);

  const handleLoadMore = useCallback(() => {
    dispatch(expandNotificationsForRequest());
  }, [dispatch]);

  const handleDismiss = useCallback(() => {
    dispatch(dismissNotificationRequest(id));
  }, [dispatch, id]);

  const handleAccept = useCallback(() => {
    dispatch(acceptNotificationRequest(id));
  }, [dispatch, id]);

  const handleMoveUp = useCallback(id => {
    const elementIndex = notifications.findIndex(item => item !== null && item.get('id') === id) - 1;
    selectChild(columnRef, elementIndex, true);
  }, [columnRef, notifications]);

  const handleMoveDown = useCallback(id => {
    const elementIndex = notifications.findIndex(item => item !== null && item.get('id') === id) + 1;
    selectChild(columnRef, elementIndex, false);
  }, [columnRef, notifications]);

  useEffect(() => {
    dispatch(fetchNotificationRequest(id));
  }, [dispatch, id]);

  useEffect(() => {
    if (accountId) {
      dispatch(fetchNotificationsForRequest(accountId));
    }
  }, [dispatch, accountId]);

  const columnTitle = intl.formatMessage(messages.title, { name: account?.get('display_name') || account?.get('username') });

  return (
    <Column bindToDocument={!multiColumn} ref={columnRef} label={columnTitle}>
      <ColumnHeader
        icon='archive'
        iconComponent={InventoryIcon}
        title={columnTitle}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
        showBackButton
        extraButton={!removed && (
          <>
            <IconButton className='column-header__button' iconComponent={VolumeOffIcon} onClick={handleDismiss} title={intl.formatMessage(messages.dismiss)} />
            <IconButton className='column-header__button' iconComponent={DoneIcon} onClick={handleAccept} title={intl.formatMessage(messages.accept)} />
          </>
        )}
      />

      <SensitiveMediaContextProvider hideMediaByDefault>
        <ScrollableList
          scrollKey={`notification_requests/${id}`}
          trackScroll={!multiColumn}
          bindToDocument={!multiColumn}
          isLoading={isLoading}
          showLoading={isLoading && notifications.size === 0}
          hasMore={hasMore}
          onLoadMore={handleLoadMore}
        >
          {notifications.map(item => (
            item && <NotificationContainer
              key={item.get('id')}
              notification={item}
              accountId={item.get('account')}
              onMoveUp={handleMoveUp}
              onMoveDown={handleMoveDown}
            />
          ))}
        </ScrollableList>
      </SensitiveMediaContextProvider>

      <Helmet>
        <title>{columnTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

NotificationRequest.propTypes = {
  multiColumn: PropTypes.bool,
  params: PropTypes.shape({
    id: PropTypes.string.isRequired,
  }),
};

export default NotificationRequest;
