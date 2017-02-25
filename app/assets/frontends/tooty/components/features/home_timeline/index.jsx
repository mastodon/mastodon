import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { Link } from 'react-router';

const messages = defineMessages({
  title: { id: 'column.home', defaultMessage: 'Home' }
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'home', 'unread']) > 0
});

const HomeTimeline = React.createClass({

  propTypes: {
    intl: React.PropTypes.object.isRequired,
    hasUnread: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  render () {
    const { intl, hasUnread } = this.props;

    return (
      <Column icon='home' active={hasUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnSettingsContainer />
        <StatusListContainer {...this.props} type='home' emptyMessage={<FormattedMessage id='empty_column.home' defaultMessage="You aren't following anyone yet. Visit {public} or use search to get started and meet other users." values={{ public: <Link to='/timelines/public'><FormattedMessage id='empty_column.home.public_timeline' defaultMessage='the public timeline' /></Link> }} />} />
      </Column>
    );
  },

});

export default connect(mapStateToProps)(injectIntl(HomeTimeline));
