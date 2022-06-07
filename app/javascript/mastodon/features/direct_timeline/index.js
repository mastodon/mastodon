import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { mountConversations, unmountConversations, expandConversations } from '../../actions/conversations';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connectDirectStream } from '../../actions/streaming';
import ConversationsListContainer from './containers/conversations_list_container';

const messages = defineMessages({
  title: { id: 'column.direct', defaultMessage: 'Direct messages' },
});

export default @connect()
@injectIntl
class DirectTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
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
    const { dispatch } = this.props;

    dispatch(mountConversations());
    dispatch(expandConversations());
    this.disconnect = dispatch(connectDirectStream());
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

  handleLoadMore = maxId => {
    this.props.dispatch(expandConversations({ maxId }));
  }

  render () {
    const { intl, hasUnread, columnId, multiColumn } = this.props;
    const pinned = !!columnId;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon='at'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        />

        <ConversationsListContainer
          trackScroll={!pinned}
          scrollKey={`direct_timeline-${columnId}`}
          timelineId='direct'
          onLoadMore={this.handleLoadMore}
          prepend={<div className='follow_requests-unlocked_explanation'><span><FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a></span></div>}
          emptyMessage={<FormattedMessage id='empty_column.direct' defaultMessage="You don't have any direct messages yet. When you send or receive one, it will show up here." />}
        />
      </Column>
    );
  }

}
