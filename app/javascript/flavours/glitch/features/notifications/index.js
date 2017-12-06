import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import {
  enterNotificationClearingMode,
  expandNotifications,
  scrollTopNotifications,
} from 'flavours/glitch/actions/notifications';
import { addColumn, removeColumn, moveColumn } from 'flavours/glitch/actions/columns';
import NotificationContainer from './containers/notification_container';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { createSelector } from 'reselect';
import { List as ImmutableList } from 'immutable';
import { debounce } from 'lodash';
import ScrollableList from 'flavours/glitch/components/scrollable_list';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' },
});

const getNotifications = createSelector([
  state => ImmutableList(state.getIn(['settings', 'notifications', 'shows']).filter(item => !item).keys()),
  state => state.getIn(['notifications', 'items']),
], (excludedTypes, notifications) => notifications.filterNot(item => excludedTypes.includes(item.get('type'))));

const mapStateToProps = state => ({
  notifications: getNotifications(state),
  localSettings:  state.get('local_settings'),
  isLoading: state.getIn(['notifications', 'isLoading'], true),
  isUnread: state.getIn(['notifications', 'unread']) > 0,
  hasMore: !!state.getIn(['notifications', 'next']),
  notifCleaningActive: state.getIn(['notifications', 'cleaningMode']),
});

/* glitch */
const mapDispatchToProps = dispatch => ({
  onEnterCleaningMode(yes) {
    dispatch(enterNotificationClearingMode(yes));
  },
  dispatch,
});

@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
export default class Notifications extends React.PureComponent {

  static propTypes = {
    columnId: PropTypes.string,
    notifications: ImmutablePropTypes.list.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    intl: PropTypes.object.isRequired,
    isLoading: PropTypes.bool,
    isUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    hasMore: PropTypes.bool,
    localSettings: ImmutablePropTypes.map,
    notifCleaningActive: PropTypes.bool,
    onEnterCleaningMode: PropTypes.func,
  };

  static defaultProps = {
    trackScroll: true,
  };

  handleScrollToBottom = debounce(() => {
    this.props.dispatch(scrollTopNotifications(false));
    this.props.dispatch(expandNotifications());
  }, 300, { leading: true });

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
    const elementIndex = this.props.notifications.findIndex(item => item.get('id') === id) - 1;
    this._selectChild(elementIndex);
  }

  handleMoveDown = id => {
    const elementIndex = this.props.notifications.findIndex(item => item.get('id') === id) + 1;
    this._selectChild(elementIndex);
  }

  _selectChild (index) {
    const element = this.column.node.querySelector(`article:nth-of-type(${index + 1}) .focusable`);

    if (element) {
      element.focus();
    }
  }

  render () {
    const { intl, notifications, shouldUpdateScroll, isLoading, isUnread, columnId, multiColumn, hasMore } = this.props;
    const pinned = !!columnId;
    const emptyMessage = <FormattedMessage id='empty_column.notifications' defaultMessage="You don't have any notifications yet. Interact with others to start the conversation." />;

    let scrollableContent = null;

    if (isLoading && this.scrollableContent) {
      scrollableContent = this.scrollableContent;
    } else if (notifications.size > 0 || hasMore) {
      scrollableContent = notifications.map((item) => (
        <NotificationContainer
          key={item.get('id')}
          notification={item}
          accountId={item.get('account')}
          onMoveUp={this.handleMoveUp}
          onMoveDown={this.handleMoveDown}
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
        hasMore={hasMore}
        emptyMessage={emptyMessage}
        onScrollToBottom={this.handleScrollToBottom}
        onScrollToTop={this.handleScrollToTop}
        onScroll={this.handleScroll}
        shouldUpdateScroll={shouldUpdateScroll}
      >
        {scrollableContent}
      </ScrollableList>
    );

    return (
      <Column
        ref={this.setColumnRef}
        name='notifications'
        extraClasses={this.props.notifCleaningActive ? 'notif-cleaning' : null}
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
          notifCleaning
          notifCleaningActive={this.props.notifCleaningActive} // this is used to toggle the header text
          onEnterCleaningMode={this.props.onEnterCleaningMode}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        {scrollContainer}
      </Column>
    );
  }

}
