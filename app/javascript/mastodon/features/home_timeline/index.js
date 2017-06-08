import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
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
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    hasFollows: PropTypes.bool,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('HOME', {}));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  render () {
    const { intl, hasUnread, hasFollows, columnId, multiColumn } = this.props;
    const pinned = !!columnId;

    let emptyMessage;

    if (hasFollows) {
      emptyMessage = <FormattedMessage id='empty_column.home.inactivity' defaultMessage='Your home feed is empty. If you have been inactive for a while, it will be regenerated for you soon.' />;
    } else {
      emptyMessage = <FormattedMessage id='empty_column.home' defaultMessage="You aren't following anyone yet. Visit {public} or use search to get started and meet other users." values={{ public: <Link to='/timelines/public'><FormattedMessage id='empty_column.home.public_timeline' defaultMessage='the public timeline' /></Link> }} />;
    }

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='home'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        <StatusListContainer
          {...this.props}
          trackScroll={!pinned}
          scrollKey={`home_timeline-${columnId}`}
          type='home'
          emptyMessage={emptyMessage}
        />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(HomeTimeline));
