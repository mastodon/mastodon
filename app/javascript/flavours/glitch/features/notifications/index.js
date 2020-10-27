import React from 'react';
import { connect } from 'react-redux';
import classNames from 'classnames';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import {
  enterNotificationClearingMode,
  expandNotifications,
  scrollTopNotifications,
  mountNotifications,
  unmountNotifications,
  loadPending,
  markNotificationsAsRead,
} from 'flavours/glitch/actions/notifications';
import { addColumn, removeColumn, moveColumn } from 'flavours/glitch/actions/columns';
import { submitMarkers } from 'flavours/glitch/actions/markers';
import NotificationContainer from './containers/notification_container';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import FilterBarContainer from './containers/filter_bar_container';
import { createSelector } from 'reselect';
import { List as ImmutableList } from 'immutable';
import { debounce } from 'lodash';
import ScrollableList from 'flavours/glitch/components/scrollable_list';
import LoadGap from 'flavours/glitch/components/load_gap';
import Icon from 'flavours/glitch/components/icon';
import compareId from 'flavours/glitch/util/compare_id';
import NotificationsPermissionBanner from './components/notifications_permission_banner';

import NotificationPurgeButtonsContainer from 'flavours/glitch/containers/notification_purge_buttons_container';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' },
  enterNotifCleaning : { id: 'notification_purge.start', defaultMessage: 'Enter notification cleaning mode' },
  markAsRead : { id: 'notifications.mark_as_read', defaultMessage: 'Mark every notification as read' },
});

const getNotifications = createSelector([
  state => state.getIn(['settings', 'notifications', 'quickFilter', 'show']),
  state => state.getIn(['settings', 'notifications', 'quickFilter', 'active']),
  state => ImmutableList(state.getIn(['settings', 'notifications', 'shows']).filter(item => !item).keys()),
  state => state.getIn(['notifications', 'items']),
], (showFilterBar, allowedType, excludedTypes, notifications) => {
  if (!showFilterBar || allowedType === 'all') {
    // used if user changed the notification settings after loading the notifications from the server
    // otherwise a list of notifications will come pre-filtered from the backend
    // we need to turn it off for FilterBar in order not to block ourselves from seeing a specific category
    return notifications.filterNot(item => item !== null && excludedTypes.includes(item.get('type')));
  }
  return notifications.filter(item => item === null || allowedType === item.get('type'));
});

const mapStateToProps = state => ({
  showFilterBar: state.getIn(['settings', 'notifications', 'quickFilter', 'show']),
  notifications: getNotifications(state),
  localSettings:  state.get('local_settings'),
  isLoading: state.getIn(['notifications', 'isLoading'], true),
  isUnread: state.getIn(['notifications', 'unread']) > 0 || state.getIn(['notifications', 'pendingItems']).size > 0,
  hasMore: state.getIn(['notifications', 'hasMore']),
  numPending: state.getIn(['notifications', 'pendingItems'], ImmutableList()).size,
  notifCleaningActive: state.getIn(['notifications', 'cleaningMode']),
  lastReadId: state.getIn(['local_settings', 'notifications', 'show_unread']) ? state.getIn(['notifications', 'readMarkerId']) : '0',
  canMarkAsRead: state.getIn(['local_settings', 'notifications', 'show_unread']) && state.getIn(['notifications', 'readMarkerId']) !== '0' && getNotifications(state).some(item => item !== null && compareId(item.get('id'), state.getIn(['notifications', 'readMarkerId'])) > 0),
  needsNotificationPermission: state.getIn(['settings', 'notifications', 'alerts']).includes(true) && state.getIn(['notifications', 'browserSupport']) && state.getIn(['notifications', 'browserPermission']) === 'default',
});

/* glitch */
const mapDispatchToProps = dispatch => ({
  onEnterCleaningMode(yes) {
    dispatch(enterNotificationClearingMode(yes));
  },
  onMarkAsRead() {
    dispatch(markNotificationsAsRead());
    dispatch(submitMarkers({ immediate: true }));
  },
  onMount() {
    dispatch(mountNotifications());
  },
  onUnmount() {
    dispatch(unmountNotifications());
  },
  dispatch,
});

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class Notifications extends React.PureComponent {

  static propTypes = {
    columnId: PropTypes.string,
    notifications: ImmutablePropTypes.list.isRequired,
    showFilterBar: PropTypes.bool.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    intl: PropTypes.object.isRequired,
    isLoading: PropTypes.bool,
    isUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    hasMore: PropTypes.bool,
    numPending: PropTypes.number,
    localSettings: ImmutablePropTypes.map,
    notifCleaningActive: PropTypes.bool,
    onEnterCleaningMode: PropTypes.func,
    onMount: PropTypes.func,
    onUnmount: PropTypes.func,
    lastReadId: PropTypes.string,
    canMarkAsRead: PropTypes.bool,
    needsNotificationPermission: PropTypes.bool,
  };

  static defaultProps = {
    trackScroll: true,
  };

  state = {
    animatingNCD: false,
  };

  handleLoadGap = (maxId) => {
    this.props.dispatch(expandNotifications({ maxId }));
  };

  handleLoadOlder = debounce(() => {
    const last = this.props.notifications.last();
    this.props.dispatch(expandNotifications({ maxId: last && last.get('id') }));
  }, 300, { leading: true });

  handleLoadPending = () => {
    this.props.dispatch(loadPending());
  };

  handleScrollToTop = debounce(() => {
    this.props.dispatch(scrollTopNotifications(true));
  }, 100);

  handleScroll = debounce(() => {
    this.props.dispatch(scrollTopNotifications(false));
  }, 100);

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('NOTIFICATIONS', {}));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setColumnRef = c => {
    this.column = c;
  }

  handleMoveUp = id => {
    const elementIndex = this.props.notifications.findIndex(item => item !== null && item.get('id') === id) - 1;
    this._selectChild(elementIndex, true);
  }

  handleMoveDown = id => {
    const elementIndex = this.props.notifications.findIndex(item => item !== null && item.get('id') === id) + 1;
    this._selectChild(elementIndex, false);
  }

  _selectChild (index, align_top) {
    const container = this.column.node;
    const element = container.querySelector(`article:nth-of-type(${index + 1}) .focusable`);

    if (element) {
      if (align_top && container.scrollTop > element.offsetTop) {
        element.scrollIntoView(true);
      } else if (!align_top && container.scrollTop + container.clientHeight < element.offsetTop + element.offsetHeight) {
        element.scrollIntoView(false);
      }
      element.focus();
    }
  }

  componentDidMount () {
    const { onMount } = this.props;
    if (onMount) {
      onMount();
    }
  }

  componentWillUnmount () {
    const { onUnmount } = this.props;
    if (onUnmount) {
      onUnmount();
    }
  }

  handleTransitionEndNCD = () => {
    this.setState({ animatingNCD: false });
  }

  onEnterCleaningMode = () => {
    this.setState({ animatingNCD: true });
    this.props.onEnterCleaningMode(!this.props.notifCleaningActive);
  }

  handleMarkAsRead = () => {
    this.props.onMarkAsRead();
  }

  render () {
    const { intl, notifications, shouldUpdateScroll, isLoading, isUnread, columnId, multiColumn, hasMore, numPending, showFilterBar, lastReadId, canMarkAsRead, needsNotificationPermission } = this.props;
    const { notifCleaning, notifCleaningActive } = this.props;
    const { animatingNCD } = this.state;
    const pinned = !!columnId;
    const emptyMessage = <FormattedMessage id='empty_column.notifications' defaultMessage="You don't have any notifications yet. Interact with others to start the conversation." />;

    let scrollableContent = null;

    const filterBarContainer = showFilterBar
      ? (<FilterBarContainer />)
      : null;

    if (isLoading && this.scrollableContent) {
      scrollableContent = this.scrollableContent;
    } else if (notifications.size > 0 || hasMore) {
      scrollableContent = notifications.map((item, index) => item === null ? (
        <LoadGap
          key={'gap:' + notifications.getIn([index + 1, 'id'])}
          disabled={isLoading}
          maxId={index > 0 ? notifications.getIn([index - 1, 'id']) : null}
          onClick={this.handleLoadGap}
        />
      ) : (
        <NotificationContainer
          key={item.get('id')}
          notification={item}
          accountId={item.get('account')}
          onMoveUp={this.handleMoveUp}
          onMoveDown={this.handleMoveDown}
          unread={lastReadId !== '0' && compareId(item.get('id'), lastReadId) > 0}
        />
      ));
    } else {
      scrollableContent = null;
    }

    this.scrollableContent = scrollableContent;

    const scrollContainer = (
      <ScrollableList
        scrollKey={`notifications-${columnId}`}
        trackScroll={!pinned}
        isLoading={isLoading}
        showLoading={isLoading && notifications.size === 0}
        hasMore={hasMore}
        numPending={numPending}
        prepend={needsNotificationPermission && <NotificationsPermissionBanner />}
        alwaysPrepend
        emptyMessage={emptyMessage}
        onLoadMore={this.handleLoadOlder}
        onLoadPending={this.handleLoadPending}
        onScrollToTop={this.handleScrollToTop}
        onScroll={this.handleScroll}
        shouldUpdateScroll={shouldUpdateScroll}
        bindToDocument={!multiColumn}
      >
        {scrollableContent}
      </ScrollableList>
    );

    const extraButtons = [];

    if (canMarkAsRead) {
      extraButtons.push(
        <button
          aria-label={intl.formatMessage(messages.markAsRead)}
          title={intl.formatMessage(messages.markAsRead)}
          onClick={this.handleMarkAsRead}
          className='column-header__button'
        >
          <Icon id='check' />
        </button>
      );
    }

    const notifCleaningButtonClassName = classNames('column-header__button', {
      'active': notifCleaningActive,
    });

    const notifCleaningDrawerClassName = classNames('ncd column-header__collapsible', {
      'collapsed': !notifCleaningActive,
      'animating': animatingNCD,
    });

    const msgEnterNotifCleaning = intl.formatMessage(messages.enterNotifCleaning);

    extraButtons.push(
      <button
        aria-label={msgEnterNotifCleaning}
        title={msgEnterNotifCleaning}
        onClick={this.onEnterCleaningMode}
        className={notifCleaningButtonClassName}
      >
        <Icon id='eraser' />
      </button>
    );

    const notifCleaningDrawer = (
      <div className={notifCleaningDrawerClassName} onTransitionEnd={this.handleTransitionEndNCD}>
        <div className='column-header__collapsible-inner nopad-drawer'>
          {(notifCleaningActive || animatingNCD) ? (<NotificationPurgeButtonsContainer />) : null }
        </div>
      </div>
    );

    return (
      <Column
        bindToDocument={!multiColumn}
        ref={this.setColumnRef}
        name='notifications'
        extraClasses={this.props.notifCleaningActive ? 'notif-cleaning' : null}
        label={intl.formatMessage(messages.title)}
      >
        <ColumnHeader
          icon='bell'
          active={isUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          localSettings={this.props.localSettings}
          extraButton={extraButtons}
          appendContent={notifCleaningDrawer}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>
        {filterBarContainer}
        {scrollContainer}
      </Column>
    );
  }

}
