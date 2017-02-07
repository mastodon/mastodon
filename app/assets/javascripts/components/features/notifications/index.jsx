import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from '../ui/components/column';
import { expandNotifications, clearNotifications } from '../../actions/notifications';
import NotificationContainer from './containers/notification_container';
import { ScrollContainer } from 'react-router-scroll';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { createSelector } from 'reselect';
import Immutable from 'immutable';
import LoadMore from '../../components/load_more';
import ClearColumnButton from './components/clear_column_button';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' }
});

const getNotifications = createSelector([
  state => Immutable.List(state.getIn(['settings', 'notifications', 'shows']).filter(item => !item).keys()),
  state => state.getIn(['notifications', 'items'])
], (excludedTypes, notifications) => notifications.filterNot(item => excludedTypes.includes(item.get('type'))));

const mapStateToProps = state => ({
  notifications: getNotifications(state),
  isLoading: state.getIn(['notifications', 'isLoading'], true)
});

const Notifications = React.createClass({

  propTypes: {
    notifications: ImmutablePropTypes.list.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    trackScroll: React.PropTypes.bool,
    intl: React.PropTypes.object.isRequired,
    isLoading: React.PropTypes.bool
  },

  getDefaultProps () {
    return {
      trackScroll: true
    };
  },

  mixins: [PureRenderMixin],

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const offset = scrollHeight - scrollTop - clientHeight;
    this._oldScrollPosition = scrollHeight - scrollTop;

    if (250 > offset && !this.props.isLoading) {
      this.props.dispatch(expandNotifications());
    }
  },

  componentDidUpdate (prevProps) {
    if (this.node.scrollTop > 0 && (prevProps.notifications.size < this.props.notifications.size && prevProps.notifications.first() !== this.props.notifications.first() && !!this._oldScrollPosition)) {
      this.node.scrollTop = this.node.scrollHeight - this._oldScrollPosition;
    }
  },

  handleLoadMore (e) {
    e.preventDefault();
    this.props.dispatch(expandNotifications());
  },

  handleClear () {
    this.props.dispatch(clearNotifications());
  },

  setRef (c) {
    this.node = c;
  },

  render () {
    const { intl, notifications, trackScroll, isLoading } = this.props;

    let loadMore = '';

    if (!isLoading && notifications.size > 0) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    const scrollableArea = (
      <div className='scrollable' onScroll={this.handleScroll} ref={this.setRef}>
        <div>
          {notifications.map(item => <NotificationContainer key={item.get('id')} notification={item} accountId={item.get('account')} />)}
          {loadMore}
        </div>
      </div>
    );

    if (trackScroll) {
      return (
        <Column icon='bell' heading={intl.formatMessage(messages.title)}>
          <ColumnSettingsContainer />
          <ClearColumnButton onClick={this.handleClear} />
          <ScrollContainer scrollKey='notifications'>
            {scrollableArea}
          </ScrollContainer>
        </Column>
      );
    } else {
      return (
        <Column icon='bell' heading={intl.formatMessage(messages.title)}>
          <ColumnSettingsContainer />
          <ClearColumnButton onClick={this.handleClear} />
          {scrollableArea}
        </Column>
      );
    }
  }

});

export default connect(mapStateToProps)(injectIntl(Notifications));
