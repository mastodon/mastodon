import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from '../ui/components/column';
import {
  refreshNotifications,
  expandNotifications
} from '../../actions/notifications';
import NotificationContainer from './containers/notification_container';
import { ScrollContainer } from 'react-router-scroll';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  title: { id: 'column.notifications', defaultMessage: 'Notifications' }
});

const mapStateToProps = state => ({
  notifications: state.getIn(['notifications', 'items'])
});

const Notifications = React.createClass({

  propTypes: {
    notifications: ImmutablePropTypes.list.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    trackScroll: React.PropTypes.bool
  },

  getDefaultProps () {
    return {
      trackScroll: true
    };
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    const { dispatch } = this.props;
    dispatch(refreshNotifications());
  },

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
          <ScrollContainer scrollKey='notifications'>
            {scrollableArea}
          </ScrollContainer>
        </Column>
      );
    } else {
      return (
        <Column icon='bell' heading={intl.formatMessage(messages.title)}>
          {scrollableArea}
        </Column>
      );
    }
  }

});

export default connect(mapStateToProps)(injectIntl(Notifications));
