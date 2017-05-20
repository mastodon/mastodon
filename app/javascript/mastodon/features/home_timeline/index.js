import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import Link from 'react-router/lib/Link';

const messages = defineMessages({
  title: { id: 'column.home', defaultMessage: 'Home' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'home', 'unread']) > 0,
  hasFollows: state.getIn(['accounts_counters', state.getIn(['meta', 'me']), 'following_count']) > 0,
});

class HomeTimeline extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    hasFollows: PropTypes.bool,
  };

  render () {
    const { intl, hasUnread, hasFollows } = this.props;

    let emptyMessage;

    if (hasFollows) {
      emptyMessage = <FormattedMessage id='empty_column.home.inactivity' defaultMessage="Your home feed is empty. If you have been inactive for a while, it will be regenerated for you soon." />;
    } else {
      emptyMessage = <FormattedMessage id='empty_column.home' defaultMessage="You aren't following anyone yet. Visit {public} or use search to get started and meet other users." values={{ public: <Link to='/timelines/public'><FormattedMessage id='empty_column.home.public_timeline' defaultMessage='the public timeline' /></Link> }} />;
    }

    return (
      <Column icon='home' active={hasUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnSettingsContainer />

        <StatusListContainer
          {...this.props}
          scrollKey='home_timeline'
          type='home'
          emptyMessage={emptyMessage}
        />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(HomeTimeline));
