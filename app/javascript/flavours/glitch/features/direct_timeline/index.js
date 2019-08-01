import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from 'flavours/glitch/features/ui/containers/status_list_container';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import { expandDirectTimeline } from 'flavours/glitch/actions/timelines';
import { mountConversations, unmountConversations, expandConversations } from 'flavours/glitch/actions/conversations';
import { addColumn, removeColumn, moveColumn } from 'flavours/glitch/actions/columns';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { connectDirectStream } from 'flavours/glitch/actions/streaming';
import { changeSetting } from 'flavours/glitch/actions/settings';
import ConversationsListContainer from './containers/conversations_list_container';

const messages = defineMessages({
  title: { id: 'column.direct', defaultMessage: 'Direct messages' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'direct', 'unread']) > 0,
  conversationsMode: state.getIn(['settings', 'direct', 'conversations']),
});

export default @connect(mapStateToProps)
@injectIntl
class DirectTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    conversationsMode: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('DIRECT', {}));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  componentDidMount () {
    const { dispatch, conversationsMode } = this.props;

    dispatch(mountConversations());

    if (conversationsMode) {
      dispatch(expandConversations());
    } else {
      dispatch(expandDirectTimeline());
    }

    this.disconnect = dispatch(connectDirectStream());
  }

  componentDidUpdate(prevProps) {
    const { dispatch, conversationsMode } = this.props;

    if (prevProps.conversationsMode && !conversationsMode) {
      dispatch(expandDirectTimeline());
    } else if (!prevProps.conversationsMode && conversationsMode) {
      dispatch(expandConversations());
    }
  }

  componentWillUnmount () {
    this.props.dispatch(unmountConversations());

    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMoreTimeline = maxId => {
    this.props.dispatch(expandDirectTimeline({ maxId }));
  }

  handleLoadMoreConversations = maxId => {
    this.props.dispatch(expandConversations({ maxId }));
  }

  handleTimelineClick = () => {
    this.props.dispatch(changeSetting(['direct', 'conversations'], false));
  }

  handleConversationsClick = () => {
    this.props.dispatch(changeSetting(['direct', 'conversations'], true));
  }

  render () {
    const { intl, hasUnread, columnId, multiColumn, conversationsMode } = this.props;
    const pinned = !!columnId;

    let contents;
    if (conversationsMode) {
      contents = (
        <ConversationsListContainer
          trackScroll={!pinned}
          scrollKey={`direct_timeline-${columnId}`}
          timelineId='direct'
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.direct' defaultMessage="You don't have any direct messages yet. When you send or receive one, it will show up here." />}
        />
      );
    } else {
      contents = (
        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`direct_timeline-${columnId}`}
          timelineId='direct'
          onLoadMore={this.handleLoadMoreTimeline}
          emptyMessage={<FormattedMessage id='empty_column.direct' defaultMessage="You don't have any direct messages yet. When you send or receive one, it will show up here." />}
        />
      );
    }

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon='envelope'
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

        <div className='notification__filter-bar'>
          <button
            className={conversationsMode ? 'active' : ''}
            onClick={this.handleConversationsClick}
          >
            <FormattedMessage
              id='direct.conversations_mode'
              defaultMessage='Conversations'
            />
          </button>
          <button
            className={conversationsMode ? '' : 'active'}
            onClick={this.handleTimelineClick}
          >
            <FormattedMessage
              id='direct.timeline_mode'
              defaultMessage='Timeline'
            />
          </button>
        </div>

        {contents}
      </Column>
    );
  }

}
