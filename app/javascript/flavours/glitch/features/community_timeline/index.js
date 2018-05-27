import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { NavLink } from 'react-router-dom';
import PropTypes from 'prop-types';
import StatusListContainer from 'flavours/glitch/features/ui/containers/status_list_container';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import { expandCommunityTimeline } from 'flavours/glitch/actions/timelines';
import { addColumn, removeColumn, moveColumn, changeColumnParams } from 'flavours/glitch/actions/columns';
import ColumnSettingsContainer from './containers/column_settings_container';
import { connectCommunityStream } from 'flavours/glitch/actions/streaming';

const messages = defineMessages({
  title: { id: 'column.community', defaultMessage: 'Local timeline' },
});

const mapStateToProps = (state, { onlyMedia }) => ({
  hasUnread: state.getIn(['timelines', `community${onlyMedia ? ':media' : ''}`, 'unread']) > 0,
});

@connect(mapStateToProps)
@injectIntl
export default class CommunityTimeline extends React.PureComponent {

  static defaultProps = {
    onlyMedia: false,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    onlyMedia: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch, onlyMedia } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('COMMUNITY', { other: { onlyMedia } }));
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
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandCommunityTimeline({ onlyMedia }));
    this.disconnect = dispatch(connectCommunityStream({ onlyMedia }));
  }

  componentDidUpdate (prevProps) {
    if (prevProps.onlyMedia !== this.props.onlyMedia) {
      const { dispatch, onlyMedia } = this.props;

      this.disconnect();
      dispatch(expandCommunityTimeline({ onlyMedia }));
      this.disconnect = dispatch(connectCommunityStream({ onlyMedia }));
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = maxId => {
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandCommunityTimeline({ maxId, onlyMedia }));
  }

  shouldUpdateScroll = (prevRouterProps, { location }) => {
    return !(location.state && location.state.mastodonModalOpen)
  }

  handleHeadlineLinkClick = e => {
    e.preventDefault();

    const { columnId, dispatch } = this.props;
    const onlyMedia = /\/media$/.test(e.currentTarget.href);

    dispatch(changeColumnParams(columnId, { other: { onlyMedia } }));
  }

  render () {
    const { intl, hasUnread, columnId, multiColumn, onlyMedia } = this.props;
    const pinned = !!columnId;

    const headline = pinned ? (
      <div className='community-timeline__section-headline'>
        <a href='/timelines/public/local' className={!onlyMedia ? 'active' : undefined} onClick={this.handleHeadlineLinkClick}>
          <FormattedMessage id='timeline.posts' defaultMessage='Toots' />
        </a>
        <a href='/timelines/public/local/media' className={onlyMedia ? 'active' : undefined} onClick={this.handleHeadlineLinkClick}>
          <FormattedMessage id='timeline.media' defaultMessage='Media' />
        </a>
      </div>
    ) : (
      <div className='community-timeline__section-headline'>
        <NavLink exact to='/timelines/public/local' replace><FormattedMessage id='timeline.posts' defaultMessage='Toots' /></NavLink>
        <NavLink exact to='/timelines/public/local/media' replace><FormattedMessage id='timeline.media' defaultMessage='Media' /></NavLink>
      </div>
    );

    return (
      <Column ref={this.setRef} name='local' label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon='users'
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
          prepend={headline}
          trackScroll={!pinned}
          scrollKey={`community_timeline-${columnId}`}
          shouldUpdateScroll={this.shouldUpdateScroll}
          timelineId={`community${onlyMedia ? ':media' : ''}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.community' defaultMessage='The local timeline is empty. Write something publicly to get the ball rolling!' />}
        />
      </Column>
    );
  }

}
