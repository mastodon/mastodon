import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from '../ui/components/column';
import { expandNotifications } from '../../actions/notifications';
import NotificationContainer from './containers/notification_container';
import { ScrollContainer } from 'react-router-scroll';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { createSelector } from 'reselect';
import Immutable from 'immutable';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' }
});

const getNotifications = createSelector([
  state => Immutable.List(state.getIn(['settings', 'notifications', 'shows']).filter(item => !item).keys()),
  state => state.getIn(['notifications', 'items'])
], (excludedTypes, notifications) => notifications.filterNot(item => excludedTypes.includes(item.get('type'))));

const mapStateToProps = state => ({
  notifications: getNotifications(state)
});

const Notifications = React.createClass({

  propTypes: {
    notifications: ImmutablePropTypes.list.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    trackScroll: React.PropTypes.bool,
    intl: React.PropTypes.object.isRequired
  },

  getDefaultProps () {
    return {
      trackScroll: true
    };
  },

  mixins: [PureRenderMixin],

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.dispatch(expandNotifications());
    }
  },

  render () {
    const { intl, notifications, trackScroll } = this.props;

    const scrollableArea = (
      <div className='scrollable' onScroll={this.handleScroll}>
        <div>
          {notifications.map(item => <NotificationContainer key={item.get('id')} notification={item} accountId={item.get('account')} />)}
        </div>
      </div>
    );

    if (trackScroll) {
      return (
        <Column icon='bell' heading={intl.formatMessage(messages.title)}>
          <ColumnSettingsContainer />
          <ScrollContainer scrollKey='notifications'>
            {scrollableArea}
          </ScrollContainer>
        </Column>
      );
    } else {
      return (
        <Column icon='bell' heading={intl.formatMessage(messages.title)}>
          <ColumnSettingsContainer />
          {scrollableArea}
        </Column>
      );
    }
  }

});

export default connect(mapStateToProps)(injectIntl(Notifications));
