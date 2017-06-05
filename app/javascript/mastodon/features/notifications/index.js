import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandNotifications, clearNotifications, scrollTopNotifications } from '../../actions/notifications';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import NotificationContainer from './containers/notification_container';
import { ScrollContainer } from 'react-router-scroll';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { createSelector } from 'reselect';
import Immutable from 'immutable';
import LoadMore from '../../components/load_more';
import ClearColumnButton from './components/clear_column_button';
import { openModal } from '../../actions/modal';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' },
  clearMessage: { id: 'notifications.clear_confirmation', defaultMessage: 'Are you sure you want to permanently clear all your notifications?' },
  clearConfirm: { id: 'notifications.clear', defaultMessage: 'Clear notifications' },
});

const getNotifications = createSelector([
  state => Immutable.List(state.getIn(['settings', 'notifications', 'shows']).filter(item => !item).keys()),
  state => state.getIn(['notifications', 'items']),
], (excludedTypes, notifications) => notifications.filterNot(item => excludedTypes.includes(item.get('type'))));

const mapStateToProps = state => ({
  notifications: getNotifications(state),
  isLoading: state.getIn(['notifications', 'isLoading'], true),
  isUnread: state.getIn(['notifications', 'unread']) > 0,
});

class Notifications extends React.PureComponent {

  static propTypes = {
    columnId: PropTypes.string,
    notifications: ImmutablePropTypes.list.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    intl: PropTypes.object.isRequired,
    isLoading: PropTypes.bool,
    isUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  static defaultProps = {
    trackScroll: true,
  };

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const offset = scrollHeight - scrollTop - clientHeight;
    this._oldScrollPosition = scrollHeight - scrollTop;

    if (250 > offset && !this.props.isLoading) {
      this.props.dispatch(expandNotifications());
    } else if (scrollTop < 100) {
      this.props.dispatch(scrollTopNotifications(true));
    } else {
      this.props.dispatch(scrollTopNotifications(false));
    }
  }

  componentDidUpdate (prevProps) {
    if (this.node.scrollTop > 0 && (prevProps.notifications.size < this.props.notifications.size && prevProps.notifications.first() !== this.props.notifications.first() && !!this._oldScrollPosition)) {
      this.node.scrollTop = this.node.scrollHeight - this._oldScrollPosition;
    }
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.props.dispatch(expandNotifications());
  }

  handleClear = () => {
    const { dispatch, intl } = this.props;

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.clearMessage),
      confirm: intl.formatMessage(messages.clearConfirm),
      onConfirm: () => dispatch(clearNotifications()),
    }));
  }

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

  setRef = (c) => {
    this.node = c;
  }

  setColumnRef = c => {
    this.column = c;
  }

  render () {
    const { intl, notifications, shouldUpdateScroll, isLoading, isUnread, columnId, multiColumn } = this.props;
    const pinned = !!columnId;

    let loadMore       = '';
    let scrollableArea = '';
    let unread         = '';
    let scrollContainer = '';

    if (!isLoading && notifications.size > 0) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    if (isUnread) {
      unread = <div className='notifications__unread-indicator' />;
    }

    if (isLoading && this.scrollableArea) {
      scrollableArea = this.scrollableArea;
    } else if (notifications.size > 0) {
      scrollableArea = (
        <div className='scrollable' onScroll={this.handleScroll} ref={this.setRef}>
          {unread}

          <div>
            {notifications.map(item => <NotificationContainer key={item.get('id')} notification={item} accountId={item.get('account')} />)}
            {loadMore}
          </div>
        </div>
      );
    } else {
      scrollableArea = (
        <div className='empty-column-indicator' ref={this.setRef}>
          <FormattedMessage id='empty_column.notifications' defaultMessage="You don't have any notifications yet. Interact with others to start the conversation." />
        </div>
      );
    }

    if (pinned) {
      scrollContainer = scrollableArea;
    } else {
      scrollContainer = (
        <ScrollContainer scrollKey={`notifications-${columnId}`} shouldUpdateScroll={shouldUpdateScroll}>
          {scrollableArea}
        </ScrollContainer>
      );
    }

    this.scrollableArea = scrollableArea;

    return (
      <Column ref={this.setColumnRef}>
        <ColumnHeader
          icon='bell'
          active={isUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        {scrollContainer}
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Notifications));
