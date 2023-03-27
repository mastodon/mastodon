import PropTypes from 'prop-types';
import React from 'react';
import { Helmet } from 'react-helmet';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import { addColumn, removeColumn, moveColumn } from 'flavours/glitch/actions/columns';
import { mountConversations, unmountConversations, expandConversations } from 'flavours/glitch/actions/conversations';
import { connectDirectStream } from 'flavours/glitch/actions/streaming';
import { expandDirectTimeline } from 'flavours/glitch/actions/timelines';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import StatusListContainer from 'flavours/glitch/features/ui/containers/status_list_container';
import ColumnSettingsContainer from './containers/column_settings_container';
import ConversationsListContainer from './containers/conversations_list_container';

const messages = defineMessages({
  title: { id: 'column.direct', defaultMessage: 'Direct messages' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'direct', 'unread']) > 0,
  conversationsMode: state.getIn(['settings', 'direct', 'conversations']),
});

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
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

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
  };

  handleLoadMoreTimeline = maxId => {
    this.props.dispatch(expandDirectTimeline({ maxId }));
  };

  handleLoadMoreConversations = maxId => {
    this.props.dispatch(expandConversations({ maxId }));
  };

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
          prepend={<div className='follow_requests-unlocked_explanation'><span><FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a></span></div>}
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
          prepend={<div className='follow_requests-unlocked_explanation'><span><FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a></span></div>}
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

        {contents}

        <Helmet>
          <title>{intl.formatMessage(messages.title)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(DirectTimeline));
