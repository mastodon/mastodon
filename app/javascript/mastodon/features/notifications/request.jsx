import PropTypes from 'prop-types';
import { useCallback, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { useSelector, useDispatch } from 'react-redux';

import {
  fetchNotificationRequest,
  fetchNotificationsForRequest,
  expandNotificationsForRequest,
  acceptNotificationRequest,
  dismissNotificationRequest,
} from 'mastodon/actions/notification_requests';
import { Column } from '@/mastodon/components/column';
import ScrollableList from 'mastodon/components/scrollable_list';
import { SensitiveMediaContextProvider } from 'mastodon/features/ui/util/sensitive_media_context';

import NotificationContainer from './containers/notification_container';
import { ColumnHeader, ColumnHeaderButton } from '@/mastodon/components/column_header';
import { CheckIcon, XIcon } from '@phosphor-icons/react';

const messages = defineMessages({
  title: { id: 'notification_requests.notifications_from', defaultMessage: 'Notifications from {name}' },
  accept: { id: 'notification_requests.accept', defaultMessage: 'Accept' },
  dismiss: { id: 'notification_requests.dismiss', defaultMessage: 'Dismiss' },
});

export const NotificationRequest = ({ multiColumn, params: { id } }) => {
  const intl = useIntl();
  const dispatch = useDispatch();
  const notificationRequest = useSelector(state => state.notificationRequests.current.item?.id === id ? state.notificationRequests.current.item : null);
  const accountId = notificationRequest?.account_id;
  const account = useSelector(state => state.getIn(['accounts', accountId]));
  const notifications = useSelector(state => state.notificationRequests.current.notifications.items);
  const isLoading = useSelector(state => state.notificationRequests.current.notifications.isLoading);
  const hasMore = useSelector(state => !!state.notificationRequests.current.notifications.next);
  const removed = useSelector(state => state.notificationRequests.current.removed);

  const handleLoadMore = useCallback(() => {
    dispatch(expandNotificationsForRequest({ accountId }));
  }, [dispatch, accountId]);

  const handleDismiss = useCallback(() => {
    dispatch(dismissNotificationRequest({ id }));
  }, [dispatch, id]);

  const handleAccept = useCallback(() => {
    dispatch(acceptNotificationRequest({ id }));
  }, [dispatch, id]);

  useEffect(() => {
    dispatch(fetchNotificationRequest({ id }));
  }, [dispatch, id]);

  useEffect(() => {
    if (accountId) {
      dispatch(fetchNotificationsForRequest({ accountId }));
    }
  }, [dispatch, accountId]);

  const columnTitle = intl.formatMessage(messages.title, { name: account?.get('display_name') || account?.get('username') });

  let explainer = null;

  if (account?.limited) {
    const isLocal = account.acct.indexOf('@') === -1;
    explainer = (
      <div className='dismissable-banner'>
        <div className='dismissable-banner__message'>
          {isLocal ? (
            <FormattedMessage id='notification_requests.explainer_for_limited_account' defaultMessage='Notifications from this account have been filtered because the account has been limited by a moderator.' />
          ) : (
            <FormattedMessage id='notification_requests.explainer_for_limited_remote_account' defaultMessage='Notifications from this account have been filtered because the account or its server has been limited by a moderator.' />
          )}
        </div>
      </div>
    );
  }

  return (
    <Column bindToDocument={!multiColumn} label={columnTitle}>
      <ColumnHeader
        withBackButton
        title={columnTitle}
        extraButtons={
          <>
            <ColumnHeaderButton icon={XIcon} onClick={handleDismiss}>
              {intl.formatMessage(messages.dismiss)}
            </ColumnHeaderButton>
            <ColumnHeaderButton
              icon={CheckIcon}
              variant='solid'
              color='accent'
              onClick={handleAccept}
            >
              {intl.formatMessage(messages.accept)}
            </ColumnHeaderButton>
          </>
        }
      />

      <SensitiveMediaContextProvider hideMediaByDefault>
        <ScrollableList
          prepend={explainer}
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
