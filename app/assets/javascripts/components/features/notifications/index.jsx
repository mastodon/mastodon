import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from '../ui/components/column';
import { expandNotifications, clearNotifications, scrollTopNotifications } from '../../actions/notifications';
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
  clearConfirm: { id: 'notifications.clear', defaultMessage: 'Clear notifications' }
});

const getNotifications = createSelector([
  state => Immutable.List(state.getIn(['settings', 'notifications', 'shows']).filter(item => !item).keys()),
  state => state.getIn(['notifications', 'items'])
], (excludedTypes, notifications) => notifications.filterNot(item => excludedTypes.includes(item.get('type'))));

const mapStateToProps = state => ({
  notifications: getNotifications(state),
  isLoading: state.getIn(['notifications', 'isLoading'], true),
  isUnread: state.getIn(['notifications', 'unread']) > 0
});

class Notifications extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleScroll = this.handleScroll.bind(this);
    this.handleLoadMore = this.handleLoadMore.bind(this);
    this.handleClear = this.handleClear.bind(this);
    this.setRef = this.setRef.bind(this);
  }

  handleScroll (e) {
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

  handleLoadMore (e) {
    e.preventDefault();
    this.props.dispatch(expandNotifications());
  }

  handleClear () {
    const { dispatch, intl } = this.props;

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.clearMessage),
      confirm: intl.formatMessage(messages.clearConfirm),
      onConfirm: () => dispatch(clearNotifications())
    }));
  }

  setRef (c) {
    this.node = c;
  }

  render () {
    const { intl, notifications, shouldUpdateScroll, isLoading, isUnread } = this.props;

    let loadMore       = '';
    let scrollableArea = '';
    let unread         = '';

    if (!isLoading && notifications.size > 0) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    if (isUnread) {
      unread = <div className='notifications__unread-indicator' />;
    }

    if (isLoading || notifications.size > 0) {
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

    return (
      <Column icon='bell' active={isUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnSettingsContainer />
        <ClearColumnButton onClick={this.handleClear} />
        <ScrollContainer scrollKey='notifications' shouldUpdateScroll={shouldUpdateScroll}>
          {scrollableArea}
        </ScrollContainer>
      </Column>
    );
  }

}

Notifications.propTypes = {
  notifications: ImmutablePropTypes.list.isRequired,
  dispatch: PropTypes.func.isRequired,
  shouldUpdateScroll: PropTypes.func,
  intl: PropTypes.object.isRequired,
  isLoading: PropTypes.bool,
  isUnread: PropTypes.bool
};

Notifications.defaultProps = {
  trackScroll: true
};

export default connect(mapStateToProps)(injectIntl(Notifications));
