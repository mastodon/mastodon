import { useCallback, useEffect, useMemo, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { createSelector } from '@reduxjs/toolkit';
import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { useDebouncedCallback } from 'use-debounce';

import DoneAllIcon from '@/material-icons/400-24px/done_all.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import { fetchNotifications } from 'mastodon/actions/notification_groups';
import { compareId } from 'mastodon/compare_id';
import { Icon } from 'mastodon/components/icon';
import { NotSignedInIndicator } from 'mastodon/components/not_signed_in_indicator';
import { useIdentity } from 'mastodon/identity_context';
import { useAppDispatch, useAppSelector } from 'mastodon/store';
import type { RootState } from 'mastodon/store';

import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { submitMarkers } from '../../actions/markers';
import {
  expandNotifications,
  scrollTopNotifications,
  loadPending,
  mountNotifications,
  unmountNotifications,
  markNotificationsAsRead,
} from '../../actions/notifications';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { LoadGap } from '../../components/load_gap';
import ScrollableList from '../../components/scrollable_list';
import { FilteredNotificationsBanner } from '../notifications/components/filtered_notifications_banner';
import NotificationsPermissionBanner from '../notifications/components/notifications_permission_banner';
import ColumnSettingsContainer from '../notifications/containers/column_settings_container';
import FilterBarContainer from '../notifications/containers/filter_bar_container';

import { NotificationGroup } from './components/notification_group';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' },
  markAsRead: {
    id: 'notifications.mark_as_read',
    defaultMessage: 'Mark every notification as read',
  },
});

/* eslint-disable @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */
// state.settings is not yet typed, so we disable some ESLint checks for those selectors
const selectSettingsNotificationsShow = (state: RootState) =>
  state.settings.getIn(['notifications', 'shows']) as ImmutableMap<
    string,
    boolean
  >;

const selectSettingsNotificationsQuickFilterShow = (state: RootState) =>
  state.settings.getIn(['notifications', 'quickFilter', 'show']) as boolean;

const selectSettingsNotificationsQuickFilterActive = (state: RootState) =>
  state.settings.getIn(['notifications', 'quickFilter', 'active']) as string;

const selectSettingsNotificationsShowUnread = (state: RootState) =>
  state.settings.getIn(['notifications', 'showUnread']) as boolean;

const selectNeedsNotificationPermission = (state: RootState) =>
  (state.settings.getIn(['notifications', 'alerts']).includes(true) &&
    state.notifications.get('browserSupport') &&
    state.notifications.get('browserPermission') === 'default' &&
    !state.settings.getIn([
      'notifications',
      'dismissPermissionBanner',
    ])) as boolean;

/* eslint-enable @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */

const getExcludedTypes = createSelector(
  [selectSettingsNotificationsShow],
  (shows) => {
    return ImmutableList(shows.filter((item) => !item).keys());
  },
);

const getNotifications = createSelector(
  [
    selectSettingsNotificationsQuickFilterShow,
    selectSettingsNotificationsQuickFilterActive,
    getExcludedTypes,
    (state: RootState) => state.notificationsGroups.groups,
  ],
  (showFilterBar, allowedType, excludedTypes, notifications) => {
    if (!showFilterBar || allowedType === 'all') {
      // used if user changed the notification settings after loading the notifications from the server
      // otherwise a list of notifications will come pre-filtered from the backend
      // we need to turn it off for FilterBar in order not to block ourselves from seeing a specific category
      return notifications.filter(
        (item) => item.type !== 'gap' || !excludedTypes.includes(item.type),
      );
    }
    return notifications.filter(
      (item) => item.type !== 'gap' || allowedType === item.type,
    );
  },
);

// const mapStateToProps = (state) => ({
//   isUnread:
//     state.getIn(['notifications', 'unread']) > 0 ||
//     state.getIn(['notifications', 'pendingItems']).size > 0,
//   numPending: state.getIn(['notifications', 'pendingItems'], ImmutableList())
//     .size,
//   canMarkAsRead:
//     state.getIn(['settings', 'notifications', 'showUnread']) &&
//     state.getIn(['notifications', 'readMarkerId']) !== '0' &&
//     getNotifications(state).some(
//       (item) =>
//         item !== null &&
//         compareId(
//           item.get('id'),
//           state.getIn(['notifications', 'readMarkerId']),
//         ) > 0,
//     ),
// });

export const Notifications: React.FC<{
  columnId?: string;
  isUnread?: boolean;
  multiColumn?: boolean;
  numPending: number;
}> = ({ isUnread, columnId, multiColumn, numPending }) => {
  const intl = useIntl();
  const notifications = useAppSelector(getNotifications);
  const dispatch = useAppDispatch();
  const isLoading = useAppSelector((s) => s.notificationsGroups.isLoading);
  const hasMore = useAppSelector((s) => s.notificationsGroups.hasMore);
  const readMarkerId = useAppSelector(
    (s) => s.notificationsGroups.readMarkerId,
  );
  const lastReadId = useAppSelector((s) =>
    selectSettingsNotificationsShowUnread(s)
      ? s.notificationsGroups.readMarkerId
      : '0',
  );
  const canMarkAsRead = useAppSelector(
    (s) =>
      selectSettingsNotificationsShowUnread(s) &&
      s.notificationsGroups.readMarkerId !== '0' &&
      notifications.some(
        (item) =>
          item.type !== 'gap' && compareId(item.group_key, readMarkerId) > 0,
      ),
  );
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

  useEffect(() => {
    dispatch(mountNotifications());

    // FIXME: remove once this becomes the main implementation
    void dispatch(fetchNotifications());

    return () => {
      dispatch(unmountNotifications());
      dispatch(scrollTopNotifications(false));
    };
  }, [dispatch]);

  const handleLoadGap = useCallback(
    (maxId: string) => {
      dispatch(expandNotifications({ maxId }));
    },
    [dispatch],
  );

  // TODO: fix this, probably incorrect
  const handleLoadOlder = useDebouncedCallback(
    () => {
      const last = notifications[notifications.length - 1];
      if (last && last.type !== 'gap')
        dispatch(expandNotifications({ maxId: last.group_key }));
    },
    300,
    { leading: true },
  );

  const handleLoadPending = useCallback(() => {
    dispatch(loadPending());
  }, [dispatch]);

  const handleScrollToTop = useDebouncedCallback(() => {
    dispatch(scrollTopNotifications(true));
  }, 100);

  const handleScroll = useDebouncedCallback(() => {
    dispatch(scrollTopNotifications(false));
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

  const filterBarContainer = signedIn ? <FilterBarContainer /> : null;

  const scrollableContent = useMemo(() => {
    if (notifications.length === 0 && !hasMore) return null;

    return notifications.map((item) =>
      item.type === 'gap' ? (
        <LoadGap
          key={item.id}
          disabled={isLoading}
          maxId={item.maxId}
          onClick={handleLoadGap}
        />
      ) : (
        <NotificationGroup
          key={item.group_key}
          notificationGroupId={item.group_key}
          onMoveUp={handleMoveUp}
          onMoveDown={handleMoveDown}
          unread={
            lastReadId !== '0' && compareId(item.group_key, lastReadId) > 0
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

  const scrollContainer = signedIn ? (
    <ScrollableList
      scrollKey={`notifications-${columnId}`}
      trackScroll={!pinned}
      isLoading={isLoading}
      showLoading={isLoading && notifications.length === 0}
      hasMore={hasMore}
      numPending={numPending}
      prepend={needsNotificationPermission && <NotificationsPermissionBanner />}
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
      {/* @ts-expect-error This component is not yet Typescript */}
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

      {filterBarContainer}

      <FilteredNotificationsBanner />

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
