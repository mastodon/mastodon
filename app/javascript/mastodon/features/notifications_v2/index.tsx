import { useCallback, useEffect, useMemo, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { createSelector } from '@reduxjs/toolkit';

import { useDebouncedCallback } from 'use-debounce';

import DoneAllIcon from '@/material-icons/400-24px/done_all.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import {
  fetchNotificationsGap,
  updateScrollPosition,
  loadPending,
  markNotificationsAsRead,
  mountNotifications,
  unmountNotifications,
} from 'mastodon/actions/notification_groups';
import { compareId } from 'mastodon/compare_id';
import { Icon } from 'mastodon/components/icon';
import { NotSignedInIndicator } from 'mastodon/components/not_signed_in_indicator';
import { useIdentity } from 'mastodon/identity_context';
import type { NotificationGap } from 'mastodon/reducers/notification_groups';
import {
  selectUnreadNotificationGroupsCount,
  selectPendingNotificationGroupsCount,
} from 'mastodon/selectors/notifications';
import {
  selectNeedsNotificationPermission,
  selectSettingsNotificationsExcludedTypes,
  selectSettingsNotificationsQuickFilterActive,
  selectSettingsNotificationsQuickFilterShow,
  selectSettingsNotificationsShowUnread,
} from 'mastodon/selectors/settings';
import { useAppDispatch, useAppSelector } from 'mastodon/store';
import type { RootState } from 'mastodon/store';

import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { submitMarkers } from '../../actions/markers';
import Column from '../../components/column';
import { ColumnHeader } from '../../components/column_header';
import { LoadGap } from '../../components/load_gap';
import ScrollableList from '../../components/scrollable_list';
import { FilteredNotificationsBanner } from '../notifications/components/filtered_notifications_banner';
import NotificationsPermissionBanner from '../notifications/components/notifications_permission_banner';
import ColumnSettingsContainer from '../notifications/containers/column_settings_container';

import { NotificationGroup } from './components/notification_group';
import { FilterBar } from './filter_bar';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' },
  markAsRead: {
    id: 'notifications.mark_as_read',
    defaultMessage: 'Mark every notification as read',
  },
});

const getNotifications = createSelector(
  [
    selectSettingsNotificationsQuickFilterShow,
    selectSettingsNotificationsQuickFilterActive,
    selectSettingsNotificationsExcludedTypes,
    (state: RootState) => state.notificationGroups.groups,
  ],
  (showFilterBar, allowedType, excludedTypes, notifications) => {
    if (!showFilterBar || allowedType === 'all') {
      // used if user changed the notification settings after loading the notifications from the server
      // otherwise a list of notifications will come pre-filtered from the backend
      // we need to turn it off for FilterBar in order not to block ourselves from seeing a specific category
      return notifications.filter(
        (item) => item.type === 'gap' || !excludedTypes.includes(item.type),
      );
    }
    return notifications.filter(
      (item) => item.type === 'gap' || allowedType === item.type,
    );
  },
);

export const Notifications: React.FC<{
  columnId?: string;
  multiColumn?: boolean;
}> = ({ columnId, multiColumn }) => {
  const intl = useIntl();
  const notifications = useAppSelector(getNotifications);
  const dispatch = useAppDispatch();
  const isLoading = useAppSelector((s) => s.notificationGroups.isLoading);
  const hasMore = notifications.at(-1)?.type === 'gap';

  const lastReadId = useAppSelector((s) =>
    selectSettingsNotificationsShowUnread(s)
      ? s.notificationGroups.lastReadId
      : '0',
  );

  const numPending = useAppSelector(selectPendingNotificationGroupsCount);

  const unreadNotificationsCount = useAppSelector(
    selectUnreadNotificationGroupsCount,
  );

  const isUnread = unreadNotificationsCount > 0;

  const canMarkAsRead =
    useAppSelector(selectSettingsNotificationsShowUnread) &&
    unreadNotificationsCount > 0;

  const needsNotificationPermission = useAppSelector(
    selectNeedsNotificationPermission,
  );

  const columnRef = useRef<Column>(null);

  const selectChild = useCallback((index: number, alignTop: boolean) => {
    const container = columnRef.current?.node as HTMLElement | undefined;

    if (!container) return;

    const element = container.querySelector<HTMLElement>(
      `article:nth-of-type(${index + 1}) .focusable`,
    );

    if (element) {
      if (alignTop && container.scrollTop > element.offsetTop) {
        element.scrollIntoView(true);
      } else if (
        !alignTop &&
        container.scrollTop + container.clientHeight <
          element.offsetTop + element.offsetHeight
      ) {
        element.scrollIntoView(false);
      }
      element.focus();
    }
  }, []);

  // Keep track of mounted components for unread notification handling
  useEffect(() => {
    dispatch(mountNotifications());

    return () => {
      dispatch(unmountNotifications());
      dispatch(updateScrollPosition({ top: false }));
    };
  }, [dispatch]);

  const handleLoadGap = useCallback(
    (gap: NotificationGap) => {
      void dispatch(fetchNotificationsGap({ gap }));
    },
    [dispatch],
  );

  const handleLoadOlder = useDebouncedCallback(
    () => {
      const gap = notifications.at(-1);
      if (gap?.type === 'gap') void dispatch(fetchNotificationsGap({ gap }));
    },
    300,
    { leading: true },
  );

  const handleLoadPending = useCallback(() => {
    dispatch(loadPending());
  }, [dispatch]);

  const handleScrollToTop = useDebouncedCallback(() => {
    dispatch(updateScrollPosition({ top: true }));
  }, 100);

  const handleScroll = useDebouncedCallback(() => {
    dispatch(updateScrollPosition({ top: false }));
  }, 100);

  useEffect(() => {
    return () => {
      handleLoadOlder.cancel();
      handleScrollToTop.cancel();
      handleScroll.cancel();
    };
  }, [handleLoadOlder, handleScrollToTop, handleScroll]);

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('NOTIFICATIONS', {}));
    }
  }, [columnId, dispatch]);

  const handleMove = useCallback(
    (dir: unknown) => {
      dispatch(moveColumn(columnId, dir));
    },
    [dispatch, columnId],
  );

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  const handleMoveUp = useCallback(
    (id: string) => {
      const elementIndex =
        notifications.findIndex(
          (item) => item.type !== 'gap' && item.group_key === id,
        ) - 1;
      selectChild(elementIndex, true);
    },
    [notifications, selectChild],
  );

  const handleMoveDown = useCallback(
    (id: string) => {
      const elementIndex =
        notifications.findIndex(
          (item) => item.type !== 'gap' && item.group_key === id,
        ) + 1;
      selectChild(elementIndex, false);
    },
    [notifications, selectChild],
  );

  const handleMarkAsRead = useCallback(() => {
    dispatch(markNotificationsAsRead());
    void dispatch(submitMarkers({ immediate: true }));
  }, [dispatch]);

  const pinned = !!columnId;
  const emptyMessage = (
    <FormattedMessage
      id='empty_column.notifications'
      defaultMessage="You don't have any notifications yet. When other people interact with you, you will see it here."
    />
  );

  const { signedIn } = useIdentity();

  const filterBar = signedIn ? <FilterBar /> : null;

  const scrollableContent = useMemo(() => {
    if (notifications.length === 0 && !hasMore) return null;

    return notifications.map((item) =>
      item.type === 'gap' ? (
        <LoadGap
          key={`${item.maxId}-${item.sinceId}`}
          disabled={isLoading}
          param={item}
          onClick={handleLoadGap}
        />
      ) : (
        <NotificationGroup
          key={item.group_key}
          notificationGroupId={item.group_key}
          onMoveUp={handleMoveUp}
          onMoveDown={handleMoveDown}
          unread={
            lastReadId !== '0' &&
            !!item.page_max_id &&
            compareId(item.page_max_id, lastReadId) > 0
          }
        />
      ),
    );
  }, [
    notifications,
    isLoading,
    hasMore,
    lastReadId,
    handleLoadGap,
    handleMoveUp,
    handleMoveDown,
  ]);

  const prepend = (
    <>
      {needsNotificationPermission && <NotificationsPermissionBanner />}
      <FilteredNotificationsBanner />
    </>
  );

  const scrollContainer = signedIn ? (
    <ScrollableList
      scrollKey={`notifications-${columnId}`}
      trackScroll={!pinned}
      isLoading={isLoading}
      showLoading={isLoading && notifications.length === 0}
      hasMore={hasMore}
      numPending={numPending}
      prepend={prepend}
      alwaysPrepend
      emptyMessage={emptyMessage}
      onLoadMore={handleLoadOlder}
      onLoadPending={handleLoadPending}
      onScrollToTop={handleScrollToTop}
      onScroll={handleScroll}
      bindToDocument={!multiColumn}
    >
      {scrollableContent}
    </ScrollableList>
  ) : (
    <NotSignedInIndicator />
  );

  const extraButton = canMarkAsRead ? (
    <button
      aria-label={intl.formatMessage(messages.markAsRead)}
      title={intl.formatMessage(messages.markAsRead)}
      onClick={handleMarkAsRead}
      className='column-header__button'
    >
      <Icon id='done-all' icon={DoneAllIcon} />
    </button>
  ) : null;

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={intl.formatMessage(messages.title)}
    >
      <ColumnHeader
        icon='bell'
        iconComponent={NotificationsIcon}
        active={isUnread}
        title={intl.formatMessage(messages.title)}
        onPin={handlePin}
        onMove={handleMove}
        onClick={handleHeaderClick}
        pinned={pinned}
        multiColumn={multiColumn}
        extraButton={extraButton}
      >
        <ColumnSettingsContainer />
      </ColumnHeader>

      {filterBar}

      {scrollContainer}

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Notifications;
