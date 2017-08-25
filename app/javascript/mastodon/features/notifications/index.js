import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandNotifications, scrollTopNotifications } from '../../actions/notifications';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import NotificationContainer from './containers/notification_container';
import { ScrollContainer } from 'react-router-scroll';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { createSelector } from 'reselect';
import { List as ImmutableList } from 'immutable';
import LoadMore from '../../components/load_more';
import { debounce } from 'lodash';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' },
});

const getNotifications = createSelector([
  state => ImmutableList(state.getIn(['settings', 'notifications', 'shows']).filter(item => !item).keys()),
  state => state.getIn(['notifications', 'items']),
], (excludedTypes, notifications) => notifications.filterNot(item => excludedTypes.includes(item.get('type'))));

const mapStateToProps = state => ({
  notifications: getNotifications(state),
  isLoading: state.getIn(['notifications', 'isLoading'], true),
  isUnread: state.getIn(['notifications', 'unread']) > 0,
  hasMore: !!state.getIn(['notifications', 'next']),
});

@connect(mapStateToProps)
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
  };

  static defaultProps = {
    trackScroll: true,
  };

  dispatchExpandNotifications = debounce(() => {
    this.props.dispatch(expandNotifications());
  }, 300, { leading: true });

  dispatchScrollToTop = debounce((top) => {
    this.props.dispatch(scrollTopNotifications(top));
  }, 100);

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const offset = scrollHeight - scrollTop - clientHeight;
    this._oldScrollPosition = scrollHeight - scrollTop;

    if (250 > offset && this.props.hasMore && !this.props.isLoading) {
      this.dispatchExpandNotifications();
    }

    if (scrollTop < 100) {
      this.dispatchScrollToTop(true);
    } else {
      this.dispatchScrollToTop(false);
    }
  }

  componentDidUpdate (prevProps) {
    if (this.node.scrollTop > 0 && (prevProps.notifications.size < this.props.notifications.size && prevProps.notifications.first() !== this.props.notifications.first() && !!this._oldScrollPosition)) {
      this.node.scrollTop = this.node.scrollHeight - this._oldScrollPosition;
    }
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.dispatchExpandNotifications();
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
    const { intl, notifications, shouldUpdateScroll, isLoading, isUnread, columnId, multiColumn, hasMore } = this.props;
    const pinned = !!columnId;

    let loadMore       = '';
    let scrollableArea = '';
    let unread         = '';
    let scrollContainer = '';

    if (!isLoading && hasMore) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    if (isUnread) {
      unread = <div className='notifications__unread-indicator' />;
    }

    if (isLoading && this.scrollableArea) {
      scrollableArea = this.scrollableArea;
    } else if (notifications.size > 0 || hasMore) {
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
