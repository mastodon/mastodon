import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandCommunityTimeline } from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn, changeColumnParams } from '../../actions/columns';
import ColumnSettingsContainer from './containers/column_settings_container';
import SectionHeadline from './components/section_headline';
import { connectCommunityStream } from '../../actions/streaming';
import classNames from 'classnames';

const messages = defineMessages({
  title: { id: 'column.community', defaultMessage: 'Local timeline' },
  showTabs: { id: 'column_header.show_tabs', defaultMessage: 'Show tabs' },
  hideTabs: { id: 'column_header.hide_tabs', defaultMessage: 'Hide tabs' },
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

  state = {
    showTabs: false,
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

  handleHeadlineLinkClick = e => {
    const { columnId, dispatch } = this.props;
    const onlyMedia = /\/media$/.test(e.currentTarget.href);

    dispatch(changeColumnParams(columnId, { other: { onlyMedia } }));
  }

  handleHeadlineToggle = () => {
    this.setState({ showTabs: !this.state.showTabs });
  }

  render () {
    const { intl, hasUnread, columnId, multiColumn, onlyMedia } = this.props;
    const { showTabs } = this.state;
    const pinned = !!columnId;

    const headline = showTabs && (
      <SectionHeadline
        timelineId='community'
        to='/timelines/public/local'
        pinned={pinned}
        onlyMedia={onlyMedia}
        onClick={this.handleHeadlineLinkClick}
      />
    );

    const toggleHeadlineButton = (
      <button
        onClick={this.handleHeadlineToggle}
        className={classNames('column-header__button', { active: showTabs })}
        title={intl.formatMessage(showTabs ? messages.hideTabs : messages.showTabs)}
        aria-label={intl.formatMessage(showTabs ? messages.hideTabs : messages.showTabs)}
        aria-pressed={showTabs ? 'true' : 'false'}
      >
        <i className='fa fa-toggle-on' />
      </button>
    );

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='users'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          extraButton={toggleHeadlineButton}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        <StatusListContainer
          prepend={headline}
          alwaysPrepend
          trackScroll={!pinned}
          scrollKey={`community_timeline-${columnId}`}
          timelineId={`community${onlyMedia ? ':media' : ''}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.community' defaultMessage='The local timeline is empty. Write something publicly to get the ball rolling!' />}
        />
      </Column>
    );
  }

}
