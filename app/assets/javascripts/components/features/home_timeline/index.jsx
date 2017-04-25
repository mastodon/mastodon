import { connect } from 'react-redux';
import PropTypes from 'prop-types';
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

class HomeTimeline extends React.PureComponent {

  render () {
    const { intl, hasUnread } = this.props;

    return (
      <Column icon='home' active={hasUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnSettingsContainer />
        <StatusListContainer {...this.props} scrollKey='home_timeline' type='home' emptyMessage={<FormattedMessage id='empty_column.home' defaultMessage="You aren't following anyone yet. Visit {public} or use search to get started and meet other users." values={{ public: <Link to='/timelines/public'><FormattedMessage id='empty_column.home.public_timeline' defaultMessage='the public timeline' /></Link> }} />} />
      </Column>
    );
  }

}

HomeTimeline.propTypes = {
  intl: PropTypes.object.isRequired,
  hasUnread: PropTypes.bool
};

export default connect(mapStateToProps)(injectIntl(HomeTimeline));
